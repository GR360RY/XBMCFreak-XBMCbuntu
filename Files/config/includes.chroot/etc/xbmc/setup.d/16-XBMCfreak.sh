#!/bin/bash

#      Copyright (C) 2005-2008 Team XBMC
#      http://www.xbmc.org
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with XBMC; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#  http://www.gnu.org/copyleft/gpl.html

xbmcUser=$1
xbmcParams=$2

#create xbmc userdata dir
mkdir -p /home/$xbmcUser/.xbmc/userdata &> /dev/null

#exclude eadir
if [ ! -f /home/$xbmcUser/.xbmc/userdata/advancedsettings.xml ] ; then
        	cat > /home/$xbmcUser/.xbmc/userdata/advancedsettings.xml << EOF
<advancedsettings>
  <video>
    <excludefromscan>
      <regexp>@eaDir</regexp>
      <regexp>@EADIR</regexp>
    </excludefromscan>
    <excludefromlisting>
      <regexp>@eaDir</regexp>
      <regexp>@EADIR</regexp>
    </excludefromlisting>
  </video>
  <audio>
    <excludefromscan>
      <regexp>@eaDir</regexp>
      <regexp>@EADIR</regexp>
    </excludefromscan>
    <excludefromlisting>
      <regexp>@eaDir</regexp>
      <regexp>@EADIR</regexp>
    </excludefromlisting>
  </audio>
</advancedsettings>
EOF
fi

#rrs feed
rm -rf /home/$xbmcUser/.xbmc/userdata/RssFeeds.xml

if [ ! -f /home/$xbmcUser/.xbmc/userdata/RssFeeds.xml ] ; then
	cat > /home/$xbmcUser/.xbmc/userdata/RssFeeds.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<rssfeeds>
  <!-- RSS feeds. To have multiple feeds, just add a feed to the set. You can also have multiple sets. !-->
  <!-- To use different sets in your skin, each must be called from skin with a unique id. !-->
  <set id="1">
    <feed updateinterval="30">http://feeds.feedburner.com/xbmcfreak-en/</feed>
  </set>
</rssfeeds>
EOF
fi

#configure torrent-transmission
sed -i "s/USER=debian-transmission/USER=$xbmcUser/g" /etc/init.d/transmission-daemon
rm -rf /var/lib/transmission-daemon/info &> /dev/null
mkdir /var/lib/transmission-daemon/info &> /dev/null
ln -s /etc/transmission-daemon/settings.json /var/lib/transmission-daemon &> /dev/null
chown -R $xbmcUser:$xbmcUser /var/lib/transmission-daemon &> /dev/null
service transmission-daemon restart >/dev/null 2>&1 &

#configure samba
sed -i "s/home\/xbmc/home\/$xbmcUser/g" /etc/samba/smb.conf
sed -i "s/guest account = xbmc/guest account = $xbmcUser/g" /etc/samba/smb.conf
service smbd restart >/dev/null 2>&1 &

#user rights rtmpdump
chown $xbmcUser:$xbmcUser /usr/local/bin/rtmpdump -R
chown $xbmcUser:$xbmcUser /usr/local/sbin/rtmp* -R

# Setup Webserver
if [ ! -f /home/$xbmcUser/.xbmc/userdata/guisettings.xml ] ; then
       	cat > /home/$xbmcUser/.xbmc/userdata/guisettings.xml << EOF
<settings>
    <services>
        <esallinterfaces>false</esallinterfaces>
        <escontinuousdelay>25</escontinuousdelay>
        <esenabled>true</esenabled>
        <esinitialdelay>750</esinitialdelay>
        <esmaxclients>20</esmaxclients>
        <esport>9777</esport>
        <esportrange>10</esportrange>
        <upnprenderer>false</upnprenderer>
        <upnpserver>false</upnpserver>
        <webserver>true</webserver>
        <webserverpassword></webserverpassword>
        <webserverport>8080</webserverport>
        <webserverusername>xbmc</webserverusername>
        <webskin>webinterface.default</webskin>
        <zeroconf>true</zeroconf>
    </services>
</settings>
EOF
else
	sed -i 's#<webserver>.*#<webserver>true</webserver>#' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
	sed -i 's#<webserverport>.*#<webserverport>8080</webserverport>#' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
	sed -i 's#<esenabled>.*#<esenabled>true</esenabled>#' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
fi

#configure sickbeard
sed -i "s/DATA_DIR=~\/.sickbeard/DATA_DIR=~\/usr\/share\/sickbeard\//g" /etc/init.d/sickbeard
sed -i "s/RUN_AS=SICKBEARD_USER/RUN_AS=$xbmcUser/g" /etc/init.d/sickbeard
chown -R $xbmcUser:$xbmcUser /usr/share/sickbeard/
service sickbeard restart >/dev/null 2>&1 &

#fix permissions
chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc
