#!/bin/bash

echo "--------------------------------"
echo "Retrieving sickbeard...         "
echo "--------------------------------"

mkdir -p $WORKPATH/Files/config/includes.chroot/usr/share/ &> /dev/null

cd $WORKPATH

git clone git://github.com/midgetspy/Sick-Beard.git $WORKPATH/Files/config/includes.chroot/usr/share/sickbeard
mkdir -p $WORKPATH/Files/config/includes.chroot/var/run/sickbeard/
mkdir -p $WORKPATH/Files/config/includes.chroot/etc/init.d/
cp $WORKPATH/Files/config/includes.chroot/usr/share/sickbeard/init.ubuntu $WORKPATH/Files/config/includes.chroot/etc/init.d/sickbeard
