# this is the helper script file that provides functions for managing the
# mount an unmount operations

HDPARM=/sbin/hdparm
UDISKCTL=/usr/bin/udisksctl
CRYPTSETUP=/sbin/cryptsetup
MOUNT_OPTIONS=nosuid,noexec,nodev

mount_crypto_volume() {
    UUID=$1
    DISC_NAME=$2
    PASSPHRASE=$3

    DEV_FILE=/dev/disk/by-uuid/${UUID}
    MOUNT_POINT=/mnt/${DISC_NAME}

    # check if disc is attached ?
    if [ -h ${DEV_FILE} ]
    then
	# unlock device
	# if the password is given as '-' we ask for a password
	
	echo + Unlock disc ${UUID} \(${DISC_NAME}\)
	
	if [ "${passphrase}" = "-" ]
	then
	    echo + Please enter passphrase for ${uuid} \(${name}\).
	    ${CRYPTSETUP} open --type luks $DEV_FILE $DISC_NAME
	else
	    echo ${PASSPHRASE} | ${CRYPTSETUP} open --luks $DEV_FILE $DISC_NAME
	fi
	
	# check if mount point exists
	if [ ! -d ${MOUNT_POINT} ]
	then
	    echo + Create mount point ${MOUNT_POINT}
	    mkdir ${MOUNT_POINT}
	    chmod 755 ${MOUNT_POINT}
	fi

	# check if mounted and otherwise mount
	echo + Mount backup to ${MOUNT_POINT}
	/bin/mountpoint -q ${MOUNT_POINT} || \
	    mount -o ${MOUNT_OPTIONS} /dev/mapper/${DISC_NAME} ${MOUNT_POINT}

    else
	echo + Disc ${DEV_FILE} \($DISC_NAME\)  is not available. Skipping.
    fi

}

poweroff_disk() {
    UUID=$1
    DEV_FILE=/dev/disk/by-uuid/${UUID}
    
    echo + Power-off HDD
    
    ${UDISKCTL} power-off -b ${DEV_FILE}
}

sleep_disk() {
    UUID=$1
    DEV_FILE=/dev/disk/by-uuid/${UUID}
    
    echo + Put HDD to rest
    if [ -f ${DEV_FILE} ] ; then
	${HDPARM} -S 1 ${DEV_FILE}
    fi
}

umount_crypto_volume() {
    UUID=$1
    DISC_NAME=$2

    DEV_FILE=/dev/disk/by-uuid/${UUID}
    MOUNT_POINT=/mnt/${DISC_NAME}

    echo + Unmount disk ${MOUNT_POINT}
    if /bin/mountpoint -q ${MOUNT_POINT}
    then
	umount ${MOUNT_POINT}
	
	${CRYPTSETUP} close ${DISC_NAME}
	sleep_disk ${DEV_FILE}
    else
	echo "+ Can't unmount ${DISC_NAME}"
    fi


}

