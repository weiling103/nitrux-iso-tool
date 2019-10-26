#! /bin/bash

set -x

printf "\n"
printf "STARTING BOOTSTRAP."
printf "\n"

export LANG=C
export LC_ALL=C


# -- Install basic packages.

printf "\n"
printf "INSTALLING BASIC PACKAGES."
printf "\n"

BASIC_PACKAGES='
apt-transport-https
ca-certificates
gnupg2 apt-utils sudo
wget
'

apt -qq update > /dev/null
apt -yy install ${BASIC_PACKAGES//\\n/ } > /dev/null


# -- Add key for elementary repositories

printf "\n"
printf "ADD REPOSITORY KEYS."
printf "\n"


	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E1F8A59 > /dev/null
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE70B91C > /dev/null


# -- Use sources.list.build to build ISO.

cp /configs/sources.list /etc/apt/sources.list


# -- Update packages list and install packages. Install desktop packages.

printf "\n"
printf "INSTALLING DESKTOP."
printf "\n"

DESKTOP_PACKAGES='
casper
cifs-utils
dhcpcd5
elementary-desktop
localechooser-data
lupin-casper
packagekit
policykit-1
user-setup
xz-utils
'

apt -qq update
apt -yy upgrade
apt -yy install ${DESKTOP_PACKAGES//\\n/ }
apt -yy -qq purge --remove gnome-software

# -- Install the kernel.

printf "\n"
printf "INSTALLING KERNEL."
printf "\n"

kfiles='
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.7/linux-headers-5.3.7-050307_5.3.7-050307.201910180652_all.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.7/linux-headers-5.3.7-050307-generic_5.3.7-050307.201910180652_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.7/linux-image-unsigned-5.3.7-050307-generic_5.3.7-050307.201910180652_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.7/linux-modules-5.3.7-050307-generic_5.3.7-050307.201910180652_amd64.deb
'

mkdir latest_kernel

for x in $kfiles; do
	printf "$x"
	wget -q -P latest_kernel $x
done

dpkg -iR latest_kernel > /dev/null
rm -r latest_kernel


# -- Add fix for https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1638842.

printf "\n"
printf "ADD MISC. FIXES."
printf "\n"

cp /configs/10-globally-managed-devices.conf /etc/NetworkManager/conf.d/


# -- Update the initramfs.

printf "\n"
printf "UPDATE INITRAMFS."
printf "\n"

cp /configs/initramfs.conf /etc/initramfs-tools/
cat /configs/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
# cp /configs/iso_scanner /usr/share/initramfs-tools/scripts/casper-premount/20iso_scan

update-initramfs -u


# -- Clean the filesystem.

printf "\n"
printf "REMOVE CASPER."
printf "\n"

apt -yy -qq purge --remove casper lupin-casper > /dev/null
apt -yy -qq autoremove > /dev/null
apt -yy -qq clean > /dev/null


printf "\n"
printf "EXITING BOOTSTRAP."
printf "\n"
