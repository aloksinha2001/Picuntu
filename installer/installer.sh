#!/system/bin/sh

#Flash/copy the recovery partition
busybox dd if=$1 of=/dev/block/mtd/by-name/recovery bs=8192

#unmount sdcard
umount /mnt/external_sd

#partition the sdcard. p1: FAT32 63Mb, start sector 2048.... p2: The rest of the card EXT4
echo "d
4
d
3
d
2
d
1
u
n
p
3

2047
n
p
1

+63M
n
p
2


d
3
t
1
b
w
" | busybox fdisk /dev/block/mmcblk0

#Create fs
mke2fs -L linuxroot -t ext4 /dev/block/mmcblk0p2

#mount new sdcard
mkdir /data/picuntu
mount -t ext4 /dev/block/mmcblk0p2 /data/picuntu

#install rootfs
busybox tar -xvzf $2 /data/picuntu/


