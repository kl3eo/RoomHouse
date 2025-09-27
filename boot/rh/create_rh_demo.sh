#!/bin/bash

mkdir -p ~/VB && cd ~/VB

if [ -f /opt/loop_rh_demo.vdi ]; then
        cp -a /opt/loop_rh_demo.vdi ./
else
        echo File /opt/loop_rh_demo.vdi not found. Exiting
        exit
fi

vboxmanage createvm --name RHU_DEMO --ostype RedHat_64 --register --basefolder `pwd`
mv loop_rh_demo.vdi RHU_DEMO/ && cd RHU_DEMO
vboxmanage modifyvm RHU_DEMO --memory 6144 --cpus 4 --audio none --firmware efi --nic1 bridged --nictype1 virtio --bridgeadapter1 enp0s31f6
vboxmanage createmedium --filename 4GDEMO.vdi --size 4096
vboxmanage storagectl RHU_DEMO --name SATA --add sata
vboxmanage storageattach RHU_DEMO --storagectl SATA --medium loop_rh_demo.vdi --port 0 --type hdd
vboxmanage storageattach RHU_DEMO --storagectl SATA --medium 4GDEMO.vdi --port 1 --type hdd
vboxmanage modifyvm RHU_DEMO --boot1 disk --boot2 none --boot3 none --boot4 none
