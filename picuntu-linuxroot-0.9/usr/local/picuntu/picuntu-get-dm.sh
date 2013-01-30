
# Install droidmote

# Conf
HM_DIR="/usr/local/picuntu"
DM_URL="http://download.g8.net/picuntu/droidmote"
APK_URL="https://play.google.com/store/apps/details?id=org.videomap.droidmoteclient"

wget -qq "$DM_URL" -O /tmp/droidmote

#ls -la /tmp/droidmote

# copyin the contents
cp -f /tmp/droidmote /usr/bin
chmod 777 /usr/bin/droidmote

#ls -al /usr/bin/droidmote

#killall -9 /usr/bin/droidmote 
kill -9 `pidof droidmote`

# Making the script
MSG="#!/bin/sh"
echo $MSG > /usr/local/picuntu/startdm.sh
MSG="droidmote 2302 12qwaszx &"
echo $MSG >> /usr/local/picuntu/startdm.sh
chmod a+x /usr/local/picuntu/startdm.sh

#ls -al /usr/local/picuntu/startdm.sh


# Making it run under startx, from next boot onwards
grep -v startdm /etc/lightdm/lightdm.conf > /tmp/dm
echo "greeter-setup-script=$HM_DIR/startdm.sh" >> /tmp/dm
cat /tmp/dm > /etc/lightdm/lightdm.conf

#cat /etc/lightdm/lightdm.conf

# making it run for now
/usr/bin/droidmote 2302 12qwaszx &

#ps auwx | grep droidmote

# APK_URL
echo "Now download the free android client from $APK_URL."
