#!/bin/sh
#
# This script is used to manage crypto volumes for backup
# purposes.
#
# Author: Martin Schobert <martin@weltregierung.de>
#

# get base directory
MY_DIR="$(dirname "$0")"

# include the helper file
. "$MY_DIR/helper.sh"

# Either the configuration file is specified via command line
# or the default confiuration file is used.
if [ "$#" -eq 2 ]
then
    CONFIG_FILE=$2
else
    # The config file has the format
    # UUID  MOUNTPOINTNAME  PASSPHRASE
    CONFIG_FILE="${MY_DIR}/config.dat"
fi

echo + Using config file ${CONFIG_FILE}.

# check file permissions of the config file
if [ $(stat -c '%a' "${CONFIG_FILE}") -ne "600" ]
then
    echo + Invalid file permissions of config ${CONFIG_FILE}. This may result in password leaks.
    exit
fi


OPERATION=$1

case $OPERATION in
    
    mount)
	
	while read  uuid name passphrase <&5; do

	    if [ "${uuid}" != "" ] ; then

		mount_crypto_volume "${uuid}" "${name}" "${passphrase}"
		
	    fi
	done 5<"${CONFIG_FILE}"
	;;

    unmount)
	
	while read uuid name passphrase; do
	    if [ "${uuid}" != "" ] ; then
		umount_crypto_volume "${uuid}" "${name}"
	    fi
	done <"${CONFIG_FILE}"
	;;

    poweroff)
	
	while read uuid name passphrase; do
	    if [ "${uuid}" != "" ] ; then
		poweroff_disk ${uuid}
	    fi
	done <"${CONFIG_FILE}"
	;;
        
    *)
	
	echo "+ Syntax: $0 COMMAND"
	echo
	echo "  COMMAND:"
	echo
	echo "    mount    - mount crypto volumes"
	echo "    unmount  - unmount crypto volumes"
	echo "    poweroff - power-off disks"
	;;
esac
