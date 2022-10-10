#!/bin/bash
IMAGE_ID=`yc compute image list | grep full | awk '{print $2}' | sort -n | tail -1`
if [ ! $IMAGE_ID ]
  then
    echo "No reddit-full image found, nothing to do."
    exit 1
fi

yc compute instance create \
   --name reddit-full \
   --hostname reddit-full \
   --core-fraction=20 \
   --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
   --metadata serial-port-enable=1 \
   --ssh-key ~/.ssh/appuser.pub \
   --create-boot-disk image-id=$IMAGE_ID
