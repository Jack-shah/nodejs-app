#!/bin/bash
cd /home/ubuntu/dist
sudo npm install
sudo npm install -g pm2
sudo pm2 start src/index.js -f --name api