#!/bin/bash
echo "Installing and starting MongoDB..."
apt-get update
apt-get install -y apt-transport-https ca-certificates
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
apt-get update
apt-get install -y mongodb-org
systemctl start mongod
systemctl enable mongod
systemctl status mongod
MDBS=$?
if [ $MDBS -eq 0 ]
  then
    echo "OK"
    exit 0
fi
echo "Failed!"
exit 1
