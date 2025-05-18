

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.77.0"
    }
  }
 
  backend "s3" {
    bucket                  = "jay-nodejs-terraform-state"
    key                     = "terraform/nodejs/staging/terraform.tfstate"
    workspace_key_prefix    = "workspaces"
    region                  = "us-east-1"
    profile                 = "default"
    shared_credentials_files = ["~/.aws/credentials"]
  }
}