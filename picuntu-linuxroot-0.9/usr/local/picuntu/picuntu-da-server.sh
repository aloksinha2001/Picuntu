#!/bin/bash
# picuntu-da-server - 0.9
# This script partitions the usb flash drive, usb external drive, SD Card
# Copies the content of linuxroot into the same

# Release date: 31-Jan-2013
#   Read the readme file for instructions
#
# Copyright Alok Sinha - asinha@g8.net
# Released under GPL V2

# TODO
	# Check webmin and joomla installation
	# Install droidmote
	# Test on MK808
	# Test welcome message
	# Picuntu readme, version and team files missing... 
	# In apt-install do a error returnn code check. Inform user, if error
		# run in silent mod
	# GUI packages
		# Make a graphics package - Gimp, ufraw, 
	# xubuntu-restricted-extra not correct - fixed
	# user lightdm did not exist. make one in the end
	# chmod 755 to /var/lib/lightdm needs to be done
		   

function conf-vars {
# Function where all the variables are configured
# Base directory

	DEV_DBG="NO"
# This needs to be changed into "" when not running on development server..
#	HST=`hostname`
#	if [ "$HST" == "monster" ]; then  
#   DEV_DBG="YES"
#	Devel="/mnt/disk2/Dev/rk3066-linux/picuntu-linuxroot-0.9"
#	home_dir="$Devel/usr/local/picuntu"
#	else
		home_dir="/usr/local/picuntu"; 
#	fi
	
	# Change this for every release
	picuntu_ver="0.9-RC2.3"
	APP_NAME="Picuntu-da-server - "
	REL_DATE="31-Jan-2013"
	BACK_T="$APP_NAME$picuntu_ver"
   export home_dir
   
# Setup programs to be called again and again
	APT="/usr/bin/apt-get -y "
	PDM="/usr/bin/pdmenu -c "
	LGR="/usr/bin/logger"
	URL_WEBMIN="http://sourceforge.net/projects/webadmin/files/webmin/1.610/webmin_1.610_all.deb/download?use_mirror=ncu"
	SRCPKG="Joomla_2.5.8-Stable-Full_Package.zip"
	SRCWWW="http://joomlacode.org/gf/download/frsrelease/17715/77262/Joomla_2.5.8-Stable-Full_Package.zip"
    KRNL_SRC_URL="http://code.google.com/p/rk3066-linux/source/browse/rk3066-kernel-0.2.tar.gz"
    
# Setting up directories/files
	TMP_SCRATCH="/tmp/picuntu.scratchpad"
	# List of apt packages, that need to be installed is found in 
    APT_FILES="/tmp/picuntu.apt"
    APT_LOG="/tmp/picuntu.apt.log"
    NTP="/usr/sbin/ntpdate"
	DIALOG="/usr/bin/dialog" 
	SEL_PKG_FILE="/tmp/pkgs.to.install"
	MAN_PKGS="/tmp/manual.install"
	TMP_DIR="/tmp/picuntu"
		mkdir -p $TMP_DIR
	WWW_DIR="/var/www"
	
	# File in which interface is defined
	IFACE_FILE="/tmp/Card.picuntu"
	DEVI_FILE="/tmp/Device.picuntu"
	MODU_FILE="/tmp/Module.picuntu"
	SUPD_FILE="/tmp/Supd.picuntu"
	
# Pdmenu file name variables
   PDM_INIT="$home_dir/picuntu-init.pdm"
	PDM_NET="$home_dir/picuntu-net.pdm"
	PDM_SND="$home_dir/picuntu-snd.pdm"
	PDM_SMB="$home_dir/picuntu-smb.pdm"
	PDM_USR="$home_dir/picuntu-usr.pdm"	
	PDM_TOP="$home_dir/picuntu-top.pdm"	
	
	
# Setting up flags here
	# file to be written, if internet is up
	INT_UP="/tmp/picuntu.net.is.working"
	# Collecting values for variables
	if [ -f "$IFACE_FILE" ]; then IFACE=`cat "$IFACE_FILE"`; else IFACE="usbnet0"; fi
	if [ -f "$DEVI_FILE" ]; then DEVI=`cat "$DEVI_FILE"`; else DEVI="UNKNOWN"; fi
	if [ -f "$MODU_FILE" ]; then MODU=`cat "$MODU_FILE"`; else MODU="8188eu"; fi

# Miscellaneous configs
   # These are the hosts I will ping to determine net status
	PNG_HST1="4.2.2.2"
	PNG_HST2="google.com"
	NT1="pool.ntp.org"
	NT2="time.nist.gov"

 		
}

function conf_apt-file {
# Setting up apt-file list here. This is what we will use, when the apps want something installed.
# This only sets the list to populate, actual installation is later.

PKG_BASE="lynx pv"

# List for Apache, mysql
PKG_AMPP="apache2 php5 apache2-mpm-prefork apache2-utils apache2.2-bin apache2.2-common libapache2-mod-php5 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libxml2 php5-cli php5-common sgml-base ssl-cert xml-core libaio1 libdbd-mysql-perl libdbi-perl libhtml-template-perl libmysqlclient18 libnet-daemon-perl libplrpc-perl libterm-readkey-perl mysql-client-5.5 mysql-client-core-5.5 mysql-common mysql-server-5.5 mysql-server-core-5.5 dbconfig-common fontconfig-config libfontconfig1 libfreetype6 libgd2-xpm libjpeg-turbo8 libjpeg8 libmcrypt4 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxpm4 php5-gd php5-mcrypt php5-mysql phpmyadmin"

# List for Sendmail/bind
PKG_MAIL="sendmail mailutils dnsutils bind9 fetchmail bind9utils guile-1.8-libs libgsasl7 libltdl7 libmailutils4 libmysqlclient18 libntlm0 m4 mailutils-common procmail python sendmail-base sendmail-bin sendmail-cf sensible-mda"

PKG_SMBA="libcups2 libfile-copy-recursive-perl samba tdb-tools update-inetd"

PKG_JOML="Joomla"

# List for Media server
PKG_MEDI="aptdaemon consolekit diffstat firefox firefox-globalmenu fontconfig fontconfig-config gettext gettext-base gir1.2-glib-2.0 groff-base hardening-includes hicolor-icon-theme intltool-debian iso-codes javascript-common libapt-pkg-perl libarchive-zip-perl libasprintf0c2 libatk1.0-0 libatk1.0-data libavcodec53 libavformat53 libcairo2 libcanberra0 libck-connector0 libclass-accessor-perl libcroco3 libcups2 libcurl3-gnutls libdbusmenu-gtk4 libdigest-hmac-perl libemail-valid-perl libexif12 libffmpegthumbnailer4 libfontconfig1 libfreetype6 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgettextpo0 libgsm1 libgtk2.0-0 libgtk2.0-bin libgtk2.0-common libice6 libio-socket-inet6-perl libio-string-perl libipc-run-perl libjasper1 libjbig0 libjpeg-turbo8 libjpeg8 libjs-prototype libltdl7 libmailtools-perl libmysqlclient18 libnet-dns-perl libnet-domain-tld-perl libnet-ip-perl libogg0 liborc-0.4-0 libpam-ck-connector libpango1.0-0 libparse-debianchangelog-perl libpixman-1-0 libpolkit-agent-1-0 libpolkit-backend-1-0 libpolkit-gobject-1-0 librtmp0 libschroedinger-1.0-0 libsm6 libsocket6-perl libspeex1 libstartup-notification0 libsub-name-perl libswscale2 libtag1-vanilla libtag1c2a libthai-data libthai0 libtheora0 libtiff5 libunistring0 liburi-perl libva1 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx1 libx11-6 libx11-data libx11-xcb1 libxau6 libxcb-render0 libxcb-shm0 libxcb-util0 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxdmcp6 libxext6 libxfixes3 libxft2 libxi6 libxinerama1 libxml2 libxrandr2 libxrender1 libxt6 lintian lsb-release man-db mediatomb-common mediatomb-daemon patchutils policykit-1 python-apt-common python3  python3-apt python3-aptdaemon python3-dbus python3-defer python3-gi python3-pkg-resources python3.2 sgml-base shared-mime-info sound-theme-freedesktop wwwconfig-common x11-common xml-core xul-ext-ubufox espeak espeak-data libespeak1 libflac8 libjack-jackd2-0 libjson0 libportaudio2 libpulse0 libsndfile1 libsonic0"

# List for Webmin
PKG_WBMN="libnet-ssleay-perl libauthen-pam-perl apt-show-versions python libapt-pkg-perl"


# List for xfce
PKG_XFCE="xubuntu-desktop wicd synaptic chromium-browser gparted vlc gstreamer0.10-alsa bluefish xubuntu-restricted-extras"

#  List for xubuntu Xtras
#PKG_XXTR="xubuntu-restricted-extras"

# List for ubuntu 
PKG_UBNT="ubuntu-desktop wicd synaptic chromium-browser gparted vlc gstreamer0.10-alsa"

# List for xubuntu Xtras
PKG_UXTR="ubuntu-restricted-extras"

# List for libreoffice
PKG_OFFC="ca-certificates-java default-jre default-jre-headless fonts-opensymbol icedtea-7-jre-jamvm java-common libatk-wrapper-java libatk-wrapper-java-jni libboost-date-time1.49.0 libcmis-0.2-2 libexttextcat-1.0-0 libexttextcat-data libgconf2-4 libhsqldb-java libhyphen0 libmythes-1.2-0 libnss3-1d libreoffice libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-style-human libreoffice-style-tango libreoffice-writer libservlet3.0-java libxerces2-java libxml-commons-external-java libxml-commons-resolver1.1-java openjdk-7-jre openjdk-7-jre-headless openjdk-7-jre-lib python-uno ttf-dejavu ttf-dejavu-extra tzdata-java uno-libs3 ure xfonts-mathml"

# Graphics pages
PKG_GFX="gimp ufraw"

# Flash
PKG_FLSH="browser-plugin-gnash gnash gnash-common gnash-cygnal gnash-dev gnash-tools"

# XRDP
PKG_XRDP="tightvncserver xrdp"

# Java
PKG_JAVA="at-spi2-core ca-certificates-java colord cpp cpp-4.7 dbus-x11 fuse gconf-service gconf-service-backend gconf2 gconf2-common gvfs gvfs-daemons gvfs-libs icedtea-7-jre-jamvm java-common libatasmart4 libatk-bridge2.0-0 libatk-wrapper-java libatk-wrapper-java-jni libatspi2.0-0 libavahi-glib1 libbonobo2-0 libbonobo2-common libcairo-gobject2 libcolord1 libdrm-nouveau2  libfontenc1 libfuse2 libgconf-2-4 libgconf2-4 libgif4 libgl1-mesa-dri libgl1-mesa-glx libgnome2-0 libgnome2-bin libgnome2-common libgnomevfs2-0 libgnomevfs2-common libgphoto2-2 libgphoto2-l10n libgphoto2-port0 libgtk-3-0 libgtk-3-bin libgtk-3-common libgusb2 libidl-common libidl0 liblcms2-2 libnspr4 libnss3 libnss3-1d liborbit2 libsane libsane-common libsecret-1-0 libsecret-common libtxc-dxtn-s2tc0 libudisks2-0 libv4l-0 libv4lconvert0 libxaw7 libxcb-glx0 libxcb-shape0 libxmu6 libxmuu1 libxtst6 libxv1 libxxf86dga1 libxxf86vm1 mtools ntfs-3g openjdk-7-jre-headless openjdk-7-jre-lib policykit-1-gnome ttf-dejavu-extra tzdata-java udisks2 x11-utils openjdk-7-jre acl"

# Gcompiler
PKG_GCC4="gcc gdb gcc-4.7 cpp cpp-4.7 binutils-gold libgcc1-dbg autoconf automake cpp-doc autotools-dev cpp-4.7-doc m4 sharutils"

# Editors
PKG_EDIT="bluefish geany"
 
}

function chk-uid {
# function to check, if I am uid
if [[ $EUID -ne 0 ]]; 
	then
  		clear
		echo "You must be root to run this, it won't work otherwise" 2>&1
		echo
		echo
		return 0
	else
		return 1
fi
 }

function initial-steps {  
# TODO: 
# This is the first thing that would be booting up,

echo "To do some initital thingy"
# Remove udev rules
# remove root bash history
# Make changes in the root bash script for color terminal
# Make changes to /etc/issue, /etc/issue.net

}

function mod-probe {
# Function that inserts a module
rmmod $MODU
/sbin/modprobe $MODU
depmod -a

}

function inst_picuntu_source {
	wget "$KRNL_SRC_URL" -O /root/picuntu-source.tar.gz
	plog "Source downloaded."
  
}

function conf-network {
# Function to configure network
dia_select_device
$PDM $PDM_TOP --menu=network_conf

}

function chk-internet {
# This function checks, if internet is running,
# If yes, it then writes $INT_UP file

# Check if net is working
rm -f $INT_UP
# Check if internet is working
# If yes, create a file $INT_UP for others to know, last net check was working 
plog "Checking internet status....."
((ping -w5 -c3 $PNG_HST1 || ping -w5 -c3 $PNG_HST1) > /dev/null 2>&1) && (touch $INT_UP; return 0)  || (rm -f $INT_UP; return 1)

}

function apt-update {
# This function is used to update and upgrade apt 

plog "Updating apt repository"
$APT update
$APT upgrade
$APT autoremove

# Incase, I was interrupted last time, I should run this.
dpkg --configure -a

# system updated, now keeping a flag to tell others, that I am updated
plog "APT updated, upgraded"

}

function man-pkg-inst {
# Function for installing manually installed packages.
# These packages cannot be installed by apt, and hence this manual step
# List of packages required to be installed are in $MAN_PKGS

echo "Read $MAN_PKGS"

case $pkg_type in
  "Webmin" )
		wget "$URL_WEBMIN" -O /tmp/webmin_1.610_all.deb; 
		dpkg -i /tmp/webmin_1.610_all.deb
    	;;
  "Joomla" )
		inst_joomla
		;;
  "SOURCE" )
		inst_picuntu_source
		;;
  "droidmote" )
		picuntu-get-dm.sh
		;;
esac

}

function inst_joomla {
	clear
	echo "Installing and base level configuring joomla"
	mkdir -p $TMP_DIR
	cd $TMP_DIR
	mkdir joomla
	cd $TMP_DIR/joomla
	/usr/bin/wget "$SRCWWW" -O "$SRCPKG"
	/usr/bin/unzip "$SRCPKG"
	rm -f $SRCPKG
	cd ..
	mv joomla/* "$WWW_DIR"
	chown -R www-data.www-data "$WWW_DIR"
	cd "$WWW_DIR"
	find . -type f -exec chmod 644 {} \;
	find . -type d -exec chmod 755 {} \;
	mysqladmin -u root -p create joomla
	echo "Please enter mysql root password, (that you configured earlier) when prompted"
	echo "We will make user joomla, pass joomla - please change it - after installation."
	mysql -u root -p -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON joomla.* TO 'joomla'@'localhost' IDENTIFIED BY 'joomla';"
	mysql -u root -p -e "FLUSH PRIVILEGES";
	echo "" > ~/.mysql_history
	service mysql restart
	service apache2 restart
	rm -f "$WWW_DIR/index.html"
	rm -rf "$TMP_DIR"
	echo "You can now point your browser to http://localhost/joomla to start detailed joomla config"

}

function apt-inst {
# Function that will take list from $apt_file and install the apts

while read LINE; do
# do something with $LINE
## Change this before dispatching
   $APT install $LINE 2>$APT_LOG
	if [ ! "$?" -eq 0 ]; then read -p "Some error in installing the files. Select package again, afte this run is complete. Check for error in $APT_LOG file, before continuing"; fi
#  $APT install $LINE 
  done < $APT_FILES

rm -f $APT_FILES
	
}

function apt-base {
# This function installs base packages, that we find must be installed before any further progresss
# Ideally, this should be a part of our original package, but, it is a sort of patch work
#
plog "Installing base packages"
PKG_LIST=$PKG_BASE
echo $PKG_LIST > $APT_FILES
apt-inst

}

function ask-initvar {

# ToDo:
 # Ask for high rez TV or low rez
 
#if [ $DEV_DBG=="YES" ]; then read -p "Launching menus... "; fi
# Set hostname
$PDM $PDM_INIT

# This reconfigures time zone data
dpkg-reconfigure tzdata
plog "Timezone configured"

# This will set the time to actual time
$NTP $NT1
$NTP $NT1
plog "Internet synchronized time setup"

# Reconfiguring the keyboard
# Do you really need this, or will we confuse the users
# dpkg-reconfigure console-setup

# Now to configure and test sound card
$PDM $PDM_SND

# Get data for username, configure
# To make a new user
#$PDM $PDM_USR

rep=1
while [ $rep -ne 0 ]
 do
	dia_user
	rep=$?
	if [ $rep -ne 0 ]; then echo ""; echo "   ******  Error ******** "; echo ""; read -p "Error in operation. Press Enter to retry.";   fi
done


# To check and load smb
# ToDo:
# Development not complete... w 
#$PDM $PDM_SMB

}

function plog {
# Function to write log in the /var/log/syslog

echo "$1"
if [ -f /usr/bin/logger ]; then $LGR "'$1'"; fi

}

function clean-up {
# This function should clean up after itself
# Check if we can delete /tmp/picuntu
plog "Cleaning up....."

LGHT="/var/lib/lightdm"
if [ -d "$LGHT" ]; then chown -R lightdm.lightdm "$LGHT" > /tmp/2; chmod 755 -R "$LGHT"; fi
	
plog "picuntu-da-server shutting down"
}

function fix_autoX {

# Fix permission issue
LGHT="/var/lib/lightdm/"
	if [ -d "$LGHT" ]; 
		then chown -R lightdm.lightdm "$LGHT" > /tmp/2; 
		chmod 755 -R "$LGHT"; 
	fi

# Fix blueman package bug
	dpkg --configure -a 2> /tmp/error
	/usr/bin/apt-get remove blueman 1>&2 > /tmp/2
	dpkg --configure -a 2> /tmp/error

}

function proc-pkg-selection {
# This function processes the packages selected into list of things to be installed.
# Reads from $PKG_SEL_FILE - Normal contents AMP, Media, Joomla etc. 
# and makes $PKG_LIST for installation
# Finally creates $PKG_FILE
# Then calls apt-inst, for installation

pkg_type=`echo $1 | tr -d '"'`

#echo "$pkg_type" | tr -d '"'

plog "$pkg_type selected"

case $pkg_type in
  "AMP" )
    	echo $PKG_AMPP >> $APT_FILES
    	;;
  "Mail" )
		echo $PKG_JOML >> $APT_FILES
		;;
  "Samba" )
		echo $PKG_SMBA >> $APT_FILES
		;;
  "Joomla" )
		echo $PKG_AMPP >> $APT_FILES
		echo "Joomla" >> $MAN_PKGS
		;;
	"Media" )
		echo $PKG_MEDI >> $APT_FILES
		;;
	"Webmin" )
		echo $PKG_WBMN >> $APT_FILES
		echo "Webmin" >> $MAN_PKGS
		;;
	"Xfce4" )
		echo $PKG_XFCE >> $APT_FILES
		echo "droidmote" >> $MAN_PKGS
		;;
#	"Xfce4Xtra" )
#		echo $PKG_XXTR >> $APT_FILES
#		;;
	"Gnome" )
		echo $PKG_UBNT >> $APT_FILES
		;;
	"GnomeXtra" )
		echo $PKG_UXTR >> $APT_FILES
		;;	
	"LibreOffice" )
		echo $PKG_OFFC >> $APT_FILES
		;;
	"GUIGRFX" )
		echo $PKG_GRFX >> $APT_FILES
		;;
	"Flash" )
		echo $PKG_FLSH >> $APT_FILES
		;;
	"Remote" )
		echo $PKG_XRDP >> $APT_FILES
		;;
	"Java" )
		echo $PKG_JAVA >> $APT_FILES
		;;
	"GCC" )
		echo $PKG_GCC4 >> $APT_FILES
		;;
	"Editors" )
		echo $PKG_EDIT >> $APT_FILES
		;;
	"Source" )
		echo "Source" >> $MAN_PKGS
		;;
	esac

apt-inst
# This is to install those packages, that cannot be installed manually
man-pkg-inst
}

function picuntu-welcome {
# Function to display startup information
TITL="Welcome to $BACK_T"

MSG="                

Release date: $REL_DATE.

This is a linux distribution based on Ubuntu 12.10, designed to run on RK3066 chipset devices. 

As you read this message, work is underway to bring in more features into the system. 

Hope you enjoy using it as much as we enjoyed building it. - PicUntu development team."

dia_box "$TITL" "$MSG"

}
# Here functions used for dialog is being created

function dia_box_time {
# Call dia_box_time 10 "Title to display" "Message to display"
left="$1"
MSG="$3"
unit="seconds"
while test $left != 0
do
	$DIALOG --sleep 1 \
		 --backtitle "$BACK_T" \
		--begin 10 40 \
		--title "$2" \
	   --infobox "$MSG  \nSeconds left: $left" 0 0
	left=`expr $left - 2`
	test $left = 1 && unit="second"
done

}

function dia_box {
# Call dia_box_time  "Title to display" "Message to display"
dialog  --cr-wrap --backtitle "$BACK_T" \
--title "$1" \
--msgbox "\n $2" 20 50

}

function dia_yesno {
# before you call this function set the followin two vaiables
# YNTITLE with the title of the box
# YNMSG with the message in the box
# Returns If yes - returns 0;If no - returns1; If escaped - returns 255  
$DIALOG --backtitle "$BACK_T" --title "$YNTITLE" --clear --yesno "$YNMSG" 10 50
return $?
}

function dia_user  {
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 


$DIALOG --title "Enter login and password for new user" --backtitle "$BACK_T" --insecure \
                --mixedform "Create a new account for yourself :" 15 50 0 \
                "User name       : " 1 1 "picuntu" 1 20 20 0 0 \
                "Password        :"      2 1    "picuntu"  2 20  20 0 1 2> $tempfile 

retval=$?


case $retval in
  0)
	USR=`sed -n 1p "$tempfile"`
	PAS1=`sed -n 2p "$tempfile"`
	# PAS2=`sed -n 3p "$tempfile"`
	/usr/sbin/useradd -m $USR -s /bin/bash -p `openssl passwd -1 $PAS1`
	retval=$?
	;;
  1)
    echo "Operation Canceled."
	retval=0
    ;;
  255)
    echo "Operation escaped"
  	retval=0
  	;;
esac

# Too complicated to get two passwords and error check... so we will accept only one password.
# Perhaps in later releases, will fix this.
#echo -e "$PAS1\n$PAS2" | passwd $USR 

return $retval

}

function dia_select_device {
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

$DIALOG --backtitle "$BACK_T" \
	--title "PicUntu - Select your device" --clear \
        --radiolist "More may be added later...  " 20 61 6 \
        "UG802"  "UG802: Complete support" ON \
        "MK808"    "MK808: Complete support" Off \
        "MX1"    "iMito MX1: No wireless support. Read Docs to use" OFF\
        "Generic"   "You are on your own :)" off  2> $tempfile

retval=$?

DEVI=`cat $tempfile`
case $DEVI in
  "UG802" )
	IFACE="wlan0"
	MODU="8188eu"
	MODU_REM="bcm40181"
	SUPP_DEV="Yes"
	IFACE_REM="eth0"
    ;;
  "MK808" )
	IFACE="eth0"
	IFACE_REM="wlan0"
	MODU="bcm40181"
	MODU_REM="8188"
	SUPP_DEV="Yes"
    ;;
  "MX1" )
	SUPP_DEV="No"
    ;;
  "Others" )
  	SUPP_DEV="No"
    ;;
esac

echo $IFACE > $IFACE_FILE
echo $DEVI > $DEVI_FILE
echo $MODU > $MODU_FILE
echo $SUPP_DEV > $SUPD_FILE

return $retval

}

function dia_select_pkg {

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

$DIALOG --backtitle "$BACK_T" \
	--title "PicUntu - Package sets to install" --clear \
        --checklist "We recommend, you select the following packages  " 22 70 14 \
        "AMP"      		"TXT - ~42/131Mb Apache2/PHP5/MySql5/phpmyadmin" ON \
        "Mail"     		"TXT - ~5/17Mb Install Mail, bind server" OFF\
        "Samba"    		"TXT - ~3/16Mb Install cifs share server" OFF\
        "Joomla"   		"TXT - Content management software" Off \
        "Media"    		"TXT - ~48/123Mb Mediatomb, dlna" off  \
        "Webmin"   		"TXT - Web based administration" OFF\
        "Xfce4"    		"GUI - ~376/1180Mb Xfce4 installation" off \
        "Gnome"    		"GUI - ~460/1410Mb Gnome installation *Buggy" off \
        "GnomeXtra"    	"GUI - Hacks, tweaks for Gnome *Buggy" off \
        "Libreoffice" 	"GUI - LibreOffice installation" off \
        "GUIGRFX"       "GUI - Picture editing tools - gimp, ufraw" off \
        "Flash"   		"GUI - Open source gnash for flash" off \
        "Remote"   		"GUI - Share your X desktop to Win/Linux/Android" off \
        "Java"    		"Dev-TXT - ~69/142Mb open JDK 7" off \
        "GCC"			"Dev-TXT - ~14/31Mb gcc and c++ compiler" off \
        "Editors" 		"Dev-GUI - Text editors. Will install xfce4" off  \
        "Source"		"Dev-TXT - PicUntu kernel source in /root" OFF 2> $tempfile

retval=$?

cat $tempfile > $SEL_PKG_FILE

case $retval in
  0)
    echo "Selection made, moving to install"
    for i in `cat $SEL_PKG_FILE`; 
    do
    	 proc-pkg-selection $i
    done
    ;;
  1)
    echo "Cancel pressed.";;
  255)
    echo "ESC pressed.";;
esac
return $retval

}

function show_help {
# Creates a variable with text that has help 
$HLP="
Welcome to $BACK_T

Picuntu-da-server will configure the PicUntu distribution for your rk3066 devices - such as MK808, UG802 etc

There are 8 different steps that need to be done for complete process

			# Step 1 : Select device
			# Step 2 : Configure network, in a loop.
			# Step 3 : APT-update
			# Step 4 : Install base packages
			# Step 5 : Basic installation
			# Step 6 : Select packages 
			# Step 7 : Choose to use the PicUntu Assistant
			# Step 8 : Cleanup
Usage: 
picuntu-da-server [--options]
or more accurately

/usr/local/picuntu/picuntu-da-server [--options]

Where options are
  null: Picuntu-da-server will run its normal course, when called witout options.. This MUST be run, first time. If you are jumping straight to any of the steps, through command line options, be aware, you would break something
  --help: You are seeing this help
  --apt: Jump to Apt-update. [Step 3]. You would want to jumpt to this level, in case you do not hav MK808, UG802, or any other device whose network, you have to configure manually. *AFTER* manual configuration of the network, you can proceed with the complete installation. BE aware, without networking, it would not work anyways.
  --pkg: Jump straight selection of packages. [Step 6]. We assume, all other things have been conifgured. 
  --net: Jump to configure the net. [Step 2]. And exit program after that.
  --ast: Jump to Picuntu Assistant. [Step 7].
  --fix-AutoX: This fixes, the permission issues for auto-login to GUI mode.
"
echo $HLP

}
# ================================

ARG=$1

# ====  Start of the program
# Setup variables
depmod -a 2>>/tmp/error
conf-vars
conf_apt-file

plog "Initial run started"

# Check if uid is root
if chk-uid; then plog "Not superuser, quitting";exit; fi
picuntu-welcome

plog "$ARG selected"



case $ARG in
  "--help" )
		plog "Help text here"
		show_help		
		exit
	    ;;
  "--pkg" )
		plog "Direct pkg selection"
		
			# Step 1 : Select device
			# Step 2 : Configure network
			# Step 3: APT-update
			# Step 4 : Install base packages
			# Step 5 : Basic installation
				# All above skipped
			# Step 6
			# All configuration work done, now ask users for the package selection
			dia_select_pkg

			# Step 7
			# Now give the control to pdmenu for further testing, if required
			YNTITLE="Picuntu assistant"
			YNMSG="Do you want to run Picuntu Assistant ?}"
			if dia_yesno; 
				then 
					$PDM $PDM_TOP
				else
					plog "Great. Time to go to bed then... bye."
					exit	
				fi	
	   exit
	    ;;
  "--apt" )
  		plog "Direct Apt selected"
		if ! chk-internet; then plog "Net not working, exiting."; exit; fi
		# Net is working going for Step 3 to 7
		plog "Net is working, now proceeding for the balance steps."
		apt-update
		apt-base
		ask-initvar
		dia_select_pkg
		$PDM $PDM_TOP
   	exit
    ;;
  "--net" )
  	plog "Direct network config selected"
   	conf-network
   	exit
    ;;
  "--AutoFix" )
	plog "Autofix selected"
	fix_autoX
	exit
	;;
  "--ast" )
   	$PDM $PDM_TOP
    ;;
    * )
			# Step 1: Select device
			dia_select_device
	
			# Step 2 : configure network, keep at it till it works
			YNTITLE="Network reconfig"
			YNMSG="Do you want to configure network again"
			if dia_yesno; 
				then 
					# Configure network
					while ! chk-internet ; do
					 conf-network
			       read -p "Enter to reconfigure, CTRL-C to exit program" brk
			       plog "Network not working, going back to reconfigure"
					done
					plog "Internet working, Network configuration completed"
				else
					plog "Network reconfig skipped"	
				fi	
			
			# Step 3: Apt-update etc.
			YNTITLE="Apt update"
			YNMSG="Do you want to update/upgrade apt. Highly Recommended for first use"
			if dia_yesno; 
				then 
					apt-update
				else
					plog "Apt update and upgrade skipped"	
				fi	
			
			# Step 4: Base packages to be installed
			# install base packages required.
			apt-base
			
			# Step 5: Configure the system
			# Ask and configure system
			ask-initvar
			
			# Step 6: Select specfic packages to be installed
			# All configuration work done, now ask users for the package selection
			dia_select_pkg
			
			# Step 7
			# Now give the control to pdmenu for further testing, if required
			YNTITLE="Picuntu assistant"
			YNMSG="Do you want to run Picuntu Assistant ?}"
			if dia_yesno; 
				then 
					$PDM $PDM_TOP
				else
					plog "Great. Time to go to bed then... bye."	
				fi	
        ;;
esac

# Step 8
clean-up
# =====================  End program
