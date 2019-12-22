This is a helper script to manage removable crypto disks from a Linux host
for backup purposes. The idea is to run the script and mount available
crypto disks and to unmount them if they are not needed for operation or when
disks are moved to an offsite location.


# Usage


To mount attached disks run:

```
$ manage_crypto_disks.sh mount
```

To unmount them run:

```
$ manage_crypto_disks.sh mount.
```

For example when you know you rotate disks Fridays, you could unmount disks
from you backup script or from cron and then power them off using the
"poweroff" option:

```
$ manage_crypto_disks.sh poweroff
```

Devices are configured in a config file. This config file stores
the disk's UUIDs, a mount point name and the LUKS passphrase. If
you do not want to store LUKS passphrases in the config file, you
could enter a dash ('-'). Then the script will prompt for a passphrase.
An example is shown below:

```
bc686425-53e6-4d7e-a51a-f47bcdac1bdb	backup_21	-
9fc10fb6-ab53-4262-8ea8-250be2c7783a	backup_22	-
809a092e-65a2-4ee7-982d-a680deadbeef	backup_23	secretsecret
120c888f-596b-4479-ac9d-53cd9969ad15	backup_24	anotherpassphrase
```

You could specify the config file as parameter:

```
$ manage_crypto_disks.sh mount disk_set_2.dat
```

# Security consideration

LUKS passphrases might be stored in a config file on the system. 
Users with elevated privileges may access the config
file and will be able to read the passphrases.

Furthermore, an attacker may get physical access to the disk that
stores the config file and is able to read the passphrase as long
as the system disk is not encrypted. Therefore, it is recommended
to use an encrypted system disk.

Recommendations:

* Properly check file permissions of the config file. The script
  does another check, but if the script is never run, you will
  not see the warning.
* If you store passphrases, then better encrypt the file system
  where the config is stored.
* You may encrypt you backup too to reduce the impact when the
  LUKS passphrase leaks.
* You could avoid storing the passphrase and enter it manually
  by using the '-' in the password field.
* If you need the config frequently on the system, you could store the
  config file in a temp file system. Then it vanishes on power-down,
  but it will not prevent local privileged users from accessing it.

License
--------

See LICENSE

