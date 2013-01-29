#!/bin/bash

# picuntu-da-server - 0.9
# Release date: 20-Dec-12
#   Read the readme file for instructions
#
# Copyright Alok Sinha - asinha@g8.net
# Released under GPL V2


TMP_DIR="/tmp/picuntu"
mkdir -p $TMP_DIR
WWW_DIR="/var/www/"
HM_DIR="/usr/local/picuntu"
SRCPKG="Joomla_2.5.8-Stable-Full_Package.zip"
SRCWWW="http://joomlacode.org/gf/download/frsrelease/17715/77262/Joomla_2.5.8-Stable-Full_Package.zip"


# ----------- CONFIGURATION ----------------

# Default home dir
HIST_FL="$HM_DIR/install.history"
FST_RN_FL="$HM_DIR/first-time-picuntu"
# Set debug mode
DBUG="FALSE"

# Where to find joomla, which joomla
#SRCPKG="Joomla_1.5.7-Stable-Full_Package.zip"
#SRCWWW="http://joomlacode.org/gf/download/frsrelease/8376/30993/$SRCPKG"

# Set logging
PLOG_FL="/tmp/picuntu_install.log"
PLOG="TRUE"
[ $PLOG == "TRUE" ] && touch $PLOG_FL



function inst_joomla {
	clear
	echo "Installing and base level configuring joomla"
	mkdir -p $TMP_DIR
	cd $TMP_DIR
	mkdir joomla
	cd joomla
	/usr/bin/wget $SRCWWW -O $SRCPKG
	/usr/bin/unzip $SRCPKG
	rm -f $SRCPKG
	cd ..
	mv joomla/* $WWW_DIR
	chown -R www-data:www-data $WWW_DIR
	cd $WWW_DIR
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
	rm -f /var/www/index.html
	rm -rf $TMP_DIR
	echo "You can now point your browser to http://localhost/joomla to start detailed joomla config"

}
echo "Joomla installation to be done"
inst_joomla
exit

