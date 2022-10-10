#!/bin/bash
apt-get update
sleep 10
if pgrep -x "apt-get" > /dev/null
then
    pkill apt-get
fi
apt-get install -y ruby-full ruby-bundler build-essential
ruby -v
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
