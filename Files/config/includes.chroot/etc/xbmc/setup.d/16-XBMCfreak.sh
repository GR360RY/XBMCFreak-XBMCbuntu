#!/bin/bash

#get current xbmc user
xbmcUser=$(getent passwd 1000 | sed -e 's/\:.*//')

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
    <feed updateinterval="30">http://www.xbmcfreak.nl/feed/</feed>
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

#fix permissions
chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc

