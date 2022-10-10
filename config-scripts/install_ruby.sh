#!/bin/bash
echo "Installing Ruby and Bundler..."
sudo apt-get update
sudo apt install -y ruby-full ruby-bundler build-essential
RV=$?
bundler -v
BV=$?
if [ $(( $RV + $BV )) -eq 0 ]
  then
    echo "OK"
    exit 0
fi
echo "Failed!"
exit 1
