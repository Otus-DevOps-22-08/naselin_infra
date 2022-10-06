#!/bin/bash
echo "Installing and starting app..."
sudo apt install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
ps ax | grep puma | grep -v grep
APPS=$?
if [ $APPS -eq 0 ]
  then
    echo "OK"
    exit 0
fi
echo "Failed!"
exit 1
