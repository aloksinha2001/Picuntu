# Boot picuntu - 0.3
# Release date: 12-Dec-12
#   Read the readme file for instructions
#
# Copyright Alok Sinha - asinha@g8.net
# Released under GPL V2


# setting up the variables
LOCN="/mnt/sdcard/picuntu"
LOG="/mnt/sdcard/picuntu.log"
FILE="/mnt/sdcard/picuntu/etc/picuntu-linux"
# This is the most likely device, when you use Memory stick
DEVC="/dev/block/sda1"
# This is the likely device when you use SD card
# DEVC="/dev/block/mmcblk0p1"
DT=`date`

# mounting the memory card
umount $LOCN
if [ ! -d "$LOCN" ]; 
  then mkdir  $LOCN
fi
/system/bin/mount -t ext4 $DEVC $LOCN


# Action, after logging
echo "--------------------------------------" >> $LOG
echo $DT >> $LOG
echo "Instructed to boot into log, created /etc/picuntu, now rebooting." >>$LOG
echo "" >> $LOG

# This is where we create the /etc/picuntu-linux and reboot
touch $FILE
reboot recovery 


