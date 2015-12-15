#!/bin/bash
set -x 

# update and install package(s)
sudo apt-get -qq update
sudo apt-get -qq install unzip

# Add ubuntu to docker group
sudo usermod -G docker ubuntu

# Restart docker service
sudo service docker restart
