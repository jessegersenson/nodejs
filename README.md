###### nodejs ############
docker build -t nodetest --build-arg NODE_VERSION=v12.13.1 --build-arg WORKING_DIR=/home/nonrootuser .
docker run --rm -it nodetest:latest /bin/bash
