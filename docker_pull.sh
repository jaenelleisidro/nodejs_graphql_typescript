#this prevent error "permission denied while trying to connect to the Docker daemon"
#sudo chmod 666 /var/run/docker.sock

#login using linux
cat .docker_pat.txt | docker login --username jisidro101 --password-stdin

#login using env variable
# echo "$DOCKER_PASSWORD" | docker login --username jisidro --password-stdin

docker pull jisidro101/nodejs:latest

docker stop container_cicd_nodejs
docker rm container_cicd_nodejs

cd  nodejs
./start.staging.sh