#!/bin/bash
set -e

# Update packages
sudo apt update
sudo apt -y upgrade

# Build DOCKER-IMAGE
IMAGE_NAME=env-ros1:melodic
MY_IP_ADDR=`hostname -I | cut -d ' ' -f1`
echo $MY_IP_ADDR
docker build -t ${IMAGE_NAME} ./ --build-arg ROS_IP=${MY_IP_ADDR}

# Create Container
CONTAINER_NAME=env-melodic
docker rm -f ${CONTAINER_NAME}
docker create -i --env="DISPLAY" --net host --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" --user="kanrisha" --gpus all --name=${CONTAINER_NAME} ${IMAGE_NAME}
docker start ${CONTAINER_NAME}
