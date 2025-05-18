#login using linux
cat .docker_pat.txt | docker login --username jisidro101 --password-stdin

#login using environment variable
#echo "$DOCKER_PASSWORD" | docker login --username jaenelleisidro --password-stdin

docker build -t nodejs ./nodejs
docker tag nodejs jisidro101/nodejs

#list docker images
docker images

#push to docker hub
docker push jisidro101/nodejs
#pause