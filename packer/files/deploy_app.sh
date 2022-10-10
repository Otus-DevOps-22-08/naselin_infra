#!/bin/bash
echo "Installing app..."
apt-get install -y git
su - ubuntu
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
