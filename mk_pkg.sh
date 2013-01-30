#!/bin/bash

# This is to make distribution package
# For picuntu

# host machine
# monster

function conf_vars {
	# Configure all variables here
	DEV_DIR="/mnt/disk2/Dev/picuntu/"
	PKG_NAME="picuntu-linuxroot"
	PRE_NAME="pre-picuntu"
	MAJ_VER="0.9"
	MIN_VER="RC3"
	REL_FIL="$PKG_NAME-$MAJ_VER-$MIN_VER"
	
	CMP_FIL="$DEV_DIR$PKG_NAME-$MAJ_VER-$MIN_VER.tgz"
	PRE_FIL="$DEV_DIR$PRE_NAME-$MAJ_VER-$MIN_VER.tgz"

	PKG_DIR="$DEV_DIR/$PKG_NAME-$MAJ_VER"
	SHA_FIL="sha"
}

function clean_pkg {
	# Clean up things in the package
	echo ""
}

function dia_tar_progress {

# (pv -n "$1" | tar xzf - -C "$2" ) 2>&1 | dialog --gauge "Compressing file..." 6 50
tar -czf "$1" "$2"

}

function mk_sha {
		# Function to make checksum files
	sha1sum "$CMP_FIL" | cut -d ' ' -f1 > "$CMP_FIL-$SHA_FIL"
	sha1sum "$PRE_FIL" | cut -d ' ' -f1 > "$PRE_FIL-$SHA_FIL"
}


function mk_tar_picuntu {
	# Make tar file
	cd $PKG_DIR
	TAR_FILE="$DEV_DIR/$PKG_NAME-$MAJ_VER-$MIN_VER.tgz"
	TDIR="."
	#echo "tar -czf $TAR_FILE $TDIR"
	dia_tar_progress "$TAR_FILE" "$TDIR"
	

}

function mk_tar_prepicuntu {
# Making pre-picuntu package
	cd $DEV_DIR

	TAR_FILE="$DEV_DIR/$PRE_NAME-$MAJ_VER-$MIN_VER.tgz"
	TDIR="pre-picuntu.sh"
#	echo "tar -czf $TAR_FILE $TDIR"
	dia_tar_progress "$TAR_FILE" "$TDIR"
}

function do_devel {
	# IF am running on development machine, then link the files on local server
	F1="/var/www/$PKG_NAME-$MAJ_VER-$MIN_VER.tgz"
	F2="/var/www/$PKG_NAME-$MAJ_VER-$MIN_VER.tgz-sha"
	F3="/var/www/$PRE_NAME-$MAJ_VER-$MIN_VER.tgz"
	F4="/var/www/$PRE_NAME-$MAJ_VER-$MIN_VER.tgz-sha"

#Remove existing links
	rm -rf "$F1"
	rm -rf "$F2"
	rm -rf "$F3"
	rm -rf "$F4"

#Make new links
	ln -s "$CMP_FIL" "$F1"
	ln -s "$CMP-$SHA_FIL" "$F2"
	ln -s "$PRE_FIL" "$F3"
	ln -s "$PRE_FIL-$SHA_FIL" "$F4"
	
}
conf_vars
mk_tar_picuntu
mk_sha
mk_tar_prepicuntu
do_devel
ls -al --sort=time "$DEV_DIR"
ls -la /var/www
