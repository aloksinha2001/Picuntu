<g:plusone size="medium"></g:plusone>

PicUntu is a Ubuntu based unix environment, created to run on RK3066 chipset devices.

<wiki:toc max_depth="2" />

=Features=
 * Based on Ubuntu Qantal 12.10
 * Minimal download - only 110Mb. Picuntu-da-server package, will download more packages, depending on your selection.
 * Comprehensive menu driven configuration - no more command lines - even in text mode.
 * Full HD - 1920 x 1080p resolution
 * CPUFREQ - Dynamic clocking upto 1.6Ghz
 * Internal Wifi is working - UG802, MK808. Balance to follow
 * Configure the following using menu mode
  * Network: Wifi, LAN, dhcp, static, gateway, routes, name server
  * Sound card
  * System performance
  * Network tools
  * Play flash on web pages
 * Manage services
  * Start, stop, status, restart running services
 * Can install PicUntu on SD Card, USB thumb drive OR USB Harddisk (Tested on 1TB Seagate Expansion Drive)
 * Once the base is installed - you can choose from to select some or all of the following packages
    # Apache, mysql: apache2 php5 mysql-server-5.5 phpmyadmin
    # Mail/Bind package: sendmail mailutils dnsutils bind9 fetchmail 
    # Windows network file server - samba
    # Content manager: Joomla. Install and configure
    # Media server
    # Webmin: Install and configure
    # xfce
    # List for Gnome
    # List for libreoffice: libreoffice 
    # Flash: browser-plugin-gnash gnash gnash-common gnash-cygnal gnash-dev gnash-tools
    # Remote Desktop Server: tightvncserver xrdp
    # Java: openjdk-7-jre-headless openjdk-7-jre-lib openjdk-7-jre
    # Gcompiler: gcc gdb gcc-4.7 cpp cpp-4.7 binutils-gold libgcc1-dbg autoconf automake cpp-doc autotools-dev 
    # Editors: bluefish geany
    # Kernel source: Yes, the kernel source can now be selected during install

=Installation Manual=
==What you need to start==
 * Of course your device
  * *UG802*, or
  * *MK808*
  * Should work on imito MX1 - not tested, and we know internal wifi does not work
 * *RAM SD card* - 4GB is enough, but you may need more, depending on what you want to do with your linux
  * Optional: You can also run your PicUntu off a USB thumb drive. However, my experience says, being an external drive, it seems to cause loose connection issues and when you need to run your server for longer period of time, it would cause a lot of jitters.
 * You need *Linux OS* - to be able to format, mount and copy the files. 
   * Coming soon: We are working on getting an image of Windows system ready. Stand by.
 * You will need *Windows OS*, to be able to flash the kernel image. If your kernel is already flashed with recovery image, you do NOT need Windows.
 * Download the [http://rk3066-linux.googlecode.com/files/ug802recovkernel.img kernel image] 
 * Download the [http://rk3066-linux.googlecode.com/files/picuntu-linuxroot-0.9b.tgz PicUntu image].

==Nifty Guide==
*Picuntu installation is a three step procedure.*
 # Install kernel image
  * Decision point: The kernel image can be installed in the main kernel space or the recovery kernel space. We of course recommend you install it on the Recovery image space. This would allow you to dual boot the Linux or Android based on your choice. 
  * You need to install the kernel image on the recovery space of your RK3066 stick set.

 # Install root file system - Pre-picuntu
  # Method 1
   * Download the Pre-picuntu tool from here.
   * Run it on your linux system (not RK3066), and answer a few questions.
   * This tool, will partition, format and copy contents.
  # Method 2:
   * Format the SDCard, as ext4 and name it linuxroot
   * On a home linux system (NOT the RK3066 stick) Unpack contents of PicUntu into a directory on Linux, become su. And copy all the contents of the directory to root of SD Card.
   * Insert the SD Card into the Android. To boot Linux from Android, you need to boot into Recovery mode.

 # Linux configuration
   * Once Linux is booted you should get a login prompt
   * Login as root, password is '12qwaszx' (without quotes). *Please change the password ASAP.*
   * If your settings were correct in the pre-picuntu stage, you should already logged on to the wifi and net should be working.
    * If not, no worries, you can still configure the network
   * As root, run the command 'picunu-da-server.sh'
   * By default, ask you for the network configuration. Enter details, of your wifi.
  * Post this step, you can now configure and install new packages manually. OR
  * You can use the automated, menu driven user friendly PicUntu-da-server package to install selected packages, configure and test sound cards etc.
  
==Detailed guide==
===Step 1===
*Preparing for install*
 * Strongly recommend, that you get rid of your stock firmware, and download a new firmware that allows you 'root' access as well as many other performance enhancing features.
 * We recommend that you use [http://www.armtvtech.com/armtvtechforum/viewtopic.php?f=12&t=775 2dark4u/Bob's finless 1.7] for UG802 and [http://www.freaktab.com/showthread.php?1971-NEW-MK808-Android-mini-TV-Player-Finless-1-5A-Custom-ROM Bob's finless 1.5a] for MK808
  * These are the latest as of Jan 4th, 2013
  * *Update: Jan 10th*, Bob's finless 1.6 have been released for MK808. Check out freaktab forums.
 * The ROM comes with all the tools you would need. Download and open the README file.
 * Follow the steps as stated in the Readme file, to get yourself Bob's finless Rom installed. *Follow it to the letter*, it will save you a lot of grief.


===Step 2===
 * *Flashing the kernel*
  * There are many ways to do this. We are presenting the simplest
  * You have a *Windows* system
   * Install RKAndroidTools v1.35 on your Windows PC following exactly the instructions provided by Bob Finless.
   * Rename the earlier [https://rk3066-linux.googlecode.com/files/ug802recovkernel.img downloaded image] as  recovery.img (overwrite any other recovery.img file already present).
   * Connect Android stick to your PC and start the RKAndroidTool v1.35 app in Windows.
   * If you have Bob's finless, Click on the Reboot and then select Reboot Bootloader
    * Alternatively, using a terminal emulator, On the Android stick, open the terminal emulator and type "su", then "reboot bootloader"
    * RKAndroidTool will emit a sound and should now detect the Android stick.
    * Flash only the new recovery.img to the recovery partition in the NAND. This takes 5 or 6 seconds, and your Android stick will immediately reboot into Android. THIS IS NORMAL.
    * If you get the "dead Android bot" with red triangle when rebooting into recovery, it means the Linux kernel image was not flashed correctly to the recovery partition. 
     * Power off, power on, and repeat the procedure above paying attention to all details, and it should work. 
   * You'll know when it works because when the Linux kernel boots correctly, you can see kernel messages scrolling on the screen.
  * You have a *Linux* system
   * Though we have not tested this ourselves, but here is a link on how you could use [http://www.slatedroid.com/topic/41219-connecting-to-a-rk3066-based-board-via-adb-on-linux/ Linux to flash your kernel]
  * You have an *Android* system
   * We have been trying to build an Android script that should take care of using Android, to flash the kernel. While in theory, it seems feasible, but so far, we have *not been able to release a stable code*
   * *If you are adventurous enough*, there is, however, a script that you can use to [http://code.google.com/p/rk3066-linux/source/browse/#git%2FPicuntuInstaller flash kernel, using Android]
   * *WARNING* [https://groups.google.com/forum/?fromgroups=#!topic/rk3066-linux/nhaz0pO-4zs Please follow this thread], for discussion on the issues around this script, else you may brick your device.
===Step 3===
*SD Card installation*
 * If you have a Windows system.
  * Option I
   * Download this image. This is a 4GB disk image of installed Linux rootfs. No formatting required.
   * Using any disk image writing software write this image on top of your 4GB SDcard/USB Flash drive
  * Option II
    * Download any live linux distribution. (live ubuntu, live gparted, knoppix)
    * Boot your windows system, using this live linux program.
    * Select Gparted from the options/menu
    * Use GParted to create an ext4 partition of at least 4GB on a USB key or a microSD card. Label the partition *linuxroot*.
    * As root, extract the tarball, and copy (using cp -a) all the files in the extracted directory to the partition labeled linuxroot. This will create a Ubuntu root filesystem on the USB key or microSD card with all the proper permissions.
   * If when you boot Linux, you don't get the LightDM login screen, it means you didn't copy the rootfs files properly (probably you weren't root) and a certain number of files don't have the correct permissions. Repeat the two steps above paying attention to the instructions!

 * If you have *Linux* system
  * The simple way
   * Download the pre-picuntu installer
   * Follow the few simple steps.
  * Difficult way
   * Use GParted to create an ext4 partition of at least 4GB on a USB key or a microSD card. Label the partition *linuxroot*.
   * As root, extract the tarball, and copy (using cp -a) all the files in the extracted directory to the partition labeled linuxroot. This will create a Ubuntu root filesystem on the USB key or microSD card with all the proper permissions.
   * If when you boot Linux, you don't get the LightDM login screen, it means you didn't copy the rootfs files properly (probably you weren't root) and a certain number of files don't have the correct permissions. Repeat the two steps above paying attention to the instructions!

===Step 4===
*Configure PicUntu*
 * PicUntu is a stripped down version of Linux. To be able to use this distribution, you would most likely need to
  * Configure the network
  * Configure the sound
  * Change your time Zone
  * Add/Remove users
  * Change keyboard layout
Finally you would also need to select the install types. Currently, there are     # Apache, mysql: apache2 php5 mysql-server-5.5 phpmyadmin
    # Mail/Bind package: sendmail mailutils dnsutils bind9 fetchmail 
    # Windows network file server - samba
    # Content manager: Joomla. Install and configure
    # Media server
    # Webmin: Install and configure
    # xfce
    # List for Gnome
    # List for libreoffice: libreoffice 
    # Flash: browser-plugin-gnash gnash gnash-common gnash-cygnal gnash-dev gnash-tools
    # Remote Desktop Server: tightvncserver xrdp
    # Java: openjdk-7-jre-headless openjdk-7-jre-lib openjdk-7-jre
    # Gcompiler: gcc gdb gcc-4.7 cpp cpp-4.7 binutils-gold libgcc1-dbg autoconf automake cpp-doc autotools-dev 
    # Editors: bluefish geany
    # Kernel source: Yes, the kernel source can now be selected during install

=Changelog=

==PicUntu 0.9 RC 2==
 * Completely redone the pre-picuntu installer
 * Fixed a bug, that prevented the xfce installation
 * Added more robust checks
 * Several bugs, that were found earlier removed from picuntu-da-server
 * Added kernel source to download
 * Desktop template made for all users.

==First Release - 0.9b==
 * Removed the bug 8188eu was going into power saving mode - added 
 * The system now tries to connect to all three types of network - by default
  * wlan0, eth0, usbnet0
 * Installed both, 8188eu (for UG802) and bcm41081 (for MK808) modules
 * Fixed OTG_DWC error that fills up the log file
 * Configured /etc/network/interfaces for the correct configuration
 * Picuntu-da-server allows you to configure network
    ** Select Access Point from drop down
    ** Configure Pass
    ** Set dhcp or static mode

=To Do=
  # Check webmin and joomla installation
  # Install droidmote
  # Test on MK808
  # Test welcome message - DONE
  # Picuntu readme, version and team files missing... 
  # In apt-install do a error returnn code check. Inform user, if error
	# run in silent mod
  # GUI packages
	# Make a graphics package - Gimp, ufraw, 
  # xubuntu-restricted-extra not correct - DONE
  # if user lightdm did not exist. make one in the end - DONE
	# chmod 755 to /var/lib/lightdm needs to be done - DONE
   * In GUI mode to configure network-manager
   * Videos will not work with hardware encoding - thus xbmc, skype, vlc and other video players do not work
  # Error code, after each packet of apt download to be checked, and if error, repeat the same

=Wish List=
 * Mediatek MT5931 wifi and Bluetooth chip Mediatek MT6622 driver
 * Mjpeg streamer : http://sourceforge.net/projects/mjpg-streamer/?source=dlp
 * Front-end for CPU frequency management
 * Some sort of video resolution selection - either at kernel level or front-end
 * Helper Frontend to compile kernels and modules
 * More hardware support... need more hardware devices for it.

=Hardware Tested=
==Core devices==
  * MK808
  * UG802

==Accessories==
 * USB Hubs
 * Wireless Keyboards
  * Chicony, Riit 12-13
 * USB Thumb drives
  * 4GB, 8GB 16GB, 32GB, 64GB
 * USB ethernet
  * BobjGear Ethernet adapter, JP10801B no9700, USB 2.0 to fast ethernet adapter
 * USB External Hard disk
  * 1TB: Seagate, WDTV, Buffalo, 2TB: Lacie,WDTV
  * Can also install on USB External disk.
 * USB sound card
 * HDMI-to-VGA convertor


=Links=

 * [http://ubuntu.g8.net First website running PicUntu]
 * Discussion on Armtvtech 
 * Discussion on Slatedroid

----

*Wiki Maintained by Alok Sinha*

*Contents of this Wiki reflect, content and real hard work put in by many developers in the open source world. Credits to all of them*
