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
apt-utils
ca-certificates
gnupg2
sudo
wget
'

apt update &> /dev/null
apt -yy install ${BASIC_PACKAGES//\\n/ }


# -- Add key for elementary repositories

printf "\n"
printf "ADD REPOSITORY KEYS."
printf "\n"


	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E1F8A59 > /dev/null
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE70B91C > /dev/null


# -- Use sources.list.build to build ISO.

cp /configs/files/sources.list /etc/apt/sources.list


# -- Update packages list and install packages. Install desktop packages.

printf "\n"
printf "INSTALLING DESKTOP."
printf "\n"

DESKTOP_PACKAGES='
casper
cifs-utils
dhcpcd5
elementary-desktop
language-pack-en
language-pack-en-base
localechooser-data
locales
lupin-casper
packagekit
policykit-1
user-setup
xz-utils
'

apt update &> /dev/null
apt -yy upgrade
apt -yy install ${DESKTOP_PACKAGES//\\n/ }
apt -yy purge --remove gnome-software &> /dev/null
apt clean &> /dev/null
apt autoclean &> /dev/null

# -- Install the kernel.

printf "\n"
printf "INSTALLING KERNEL."
printf "\n"

kfiles='
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.8/linux-headers-5.3.8-050308_5.3.8-050308.201910290940_all.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.8/linux-headers-5.3.8-050308-generic_5.3.8-050308.201910290940_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.8/linux-image-unsigned-5.3.8-050308-generic_5.3.8-050308.201910290940_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.8/linux-modules-5.3.8-050308-generic_5.3.8-050308.201910290940_amd64.deb
'

mkdir latest_kernel

for x in $kfiles; do
	printf "$x"
	wget -q -P latest_kernel $x
done

dpkg -iR latest_kernel &> /dev/null
rm -r latest_kernel


# -- Add fix for https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1638842.

printf "\n"
printf "ADD MISC. FIXES."
printf "\n"

cp /configs/files/10-globally-managed-devices.conf /etc/NetworkManager/conf.d/


# -- Update the initramfs.

printf "\n"
printf "UPDATE INITRAMFS."
printf "\n"

cp /configs/files/initramfs.conf /etc/initramfs-tools/
cat /configs/files/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
# cp /configs/files/iso_scanner /usr/share/initramfs-tools/scripts/casper-premount/20iso_scan

update-initramfs -u


# -- Clean the filesystem.

printf "\n"
printf "REMOVE CASPER."
printf "\n"

REMOVE_PACKAGES='
casper
lupin-casper
'

/usr/bin/dpkg --remove --no-triggers --force-remove-essential --force-bad-path ${REMOVE_PACKAGES//\\n/ } &> /dev/null


printf "\n"
printf "EXITING BOOTSTRAP."
printf "\n"
