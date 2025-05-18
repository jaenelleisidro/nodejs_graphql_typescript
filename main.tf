variable aws_access_key{
    type = string
}
variable aws_secret_key{
    type = string
}

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


# # 1. Create vpc

resource "aws_vpc" "nodejs-stage-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "nodejs-stage-vpc"
  }
}

# # 2. Create Internet Gateway

resource "aws_internet_gateway" "nodejs-stage-gw" {
  vpc_id = aws_vpc.nodejs-stage-vpc.id
}

# # 3. Create Custom Route Table

resource "aws_route_table" "nodejs-stage-route-table" {
  vpc_id = aws_vpc.nodejs-stage-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nodejs-stage-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.nodejs-stage-gw.id
  }

  tags = {
    Name = "nodejs-stage-route-table"
  }
}

# # 4. Create a Subnet 

resource "aws_subnet" "nodejs-stage-subnet" {
  vpc_id            = aws_vpc.nodejs-stage-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "nodejs-stage-subnet"
  }
}

# # 5. Associate subnet with Route Table
resource "aws_route_table_association" "nodejs-stage-ta" {
  subnet_id      = aws_subnet.nodejs-stage-subnet.id
  route_table_id = aws_route_table.nodejs-stage-route-table.id
}


# # 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.nodejs-stage-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# # 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "nodejs-stage-nic" {
  subnet_id       = aws_subnet.nodejs-stage-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# # 8. Assign an elastic IP to the network interface created in step 7

# resource "aws_eip" "nodejs-stage-eip" {
#   vpc                       = true
#   network_interface         = aws_network_interface.nodejs-stage-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.nodejs-stage-gw]
# }

resource "aws_eip" "nodejs-stage-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.nodejs-stage-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.nodejs-stage-gw,aws_instance.nodejs-stage-instance]
  instance = aws_instance.nodejs-stage-instance.id
}


output "server_public_ip" {
  value = aws_eip.nodejs-stage-eip.public_ip
}

# # 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "nodejs-stage-instance" {
  ami               = "ami-0c7217cdde317cfec"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "nodejs-stage-keypair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nodejs-stage-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                # sudo apt install apache2 -y
                # sudo systemctl start apache2
                # sudo bash -c 'echo your very first web server > /var/www/html/index.html'

                curl -sSL https://get.docker.com/ | sh
                
                echo "$DOCKER_PASSWORD" | docker login --username jaenelleisidro --password-stdin

                EOF
  tags = {
    Name = "nodejs-stage-instance"
  }
}



output "server_private_ip" {
  value = aws_instance.nodejs-stage-instance.private_ip
}

output "server_id" {
  value = aws_instance.nodejs-stage-instance.id
}




resource "aws_s3_bucket" "nodejs-core-staging-file" {
  bucket = "nodejs-core-staging-file"

  tags = {
    Name        = "nodejs-core-staging-file"
    Environment = "Staging"
  }
}

//#######################################################################
// this create sns sqs infra


resource "aws_sns_topic" "user_leads_sns" {
  name = "nodejs_staging_user_leads_new_topic"
}

resource "aws_sqs_queue" "user_leads_new_queue" {
  name = "nodejs_staging_user_leads_new_queue"
}

//subscribe sqs to sns
resource "aws_sns_topic_subscription" "user_leads_new_queue_target" {
  topic_arn = aws_sns_topic.user_leads_new_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_leads_new_queue.arn
}

