#!/bin/bash
if [ ! -d /home/ubuntu/dist ]; then
    echo "Fresh EC2 Instance"
    exit 0
else
    cd /home/ubuntu/dist
    sudo pm2 stop api
    sudo pm2 delete api
    cd /home/ubuntu && sudo rm -rf dist
fi