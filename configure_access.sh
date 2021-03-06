#!/bin/sh

# This script automates the procedure by creating the 'debug_probe'
# user group, adding the current user to that group and
# installing the udev rules at once. Note that since adding users
# to a group does not affect current logged in users, you will
# need to re-login for the changes to take effect.

set -e

# The name of the group of users that should have access to debug
# pods. Feel free to change it as you like.
group="debug_probe"

# Create the group and add the current user to it.
user=`whoami`
sudo groupadd -f $group
sudo usermod -a -G $group $user

# Install the udev rule for Keil ULINK2 pods.
tmpfile=`mktemp`
cat >$tmpfile <<end
# Keil ULINK2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="c251", ATTRS{idProduct}=="2722", \
    MODE:="0666", GROUP:="$group", SYMLINK+="ulink_%n"
end
dest=/etc/udev/rules.d/49-ulink.rules
sudo mv $tmpfile $dest
sudo chown root:root $dest
sudo chmod 644 $dest

# Install the udev rule for ST-Link/V2 pods.
tmpfile=`mktemp`
cat >$tmpfile <<end
# ST-Link/V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
    MODE:="0666", GROUP:="$group", SYMLINK+="stlink_%n"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
    MODE:="0666", GROUP:="$group", SYMLINK+="stlink_%n"
end
dest=/etc/udev/rules.d/49-stlink.rules
sudo mv $tmpfile $dest
sudo chown root:root $dest
sudo chmod 644 $dest

# Ask udev to pick up the new rules.
sudo udevadm control --reload-rules
sudo udevadm trigger
