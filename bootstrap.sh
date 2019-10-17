#! /bin/bash

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
casper
cifs-utils
dhcpcd5
fuse
gnupg2 
localechooser-data
lupin-casper
phonon4qt5
phonon4qt5-backend-vlc
sudo
user-setup
wget 
xz-utils
'

apt -qq update
apt -yy install ${BASIC_PACKAGES//\\n/ }


# -- Add key for KDE Neon repositories

printf "\n"
printf "ADD REPOSITORY KEYS."
printf "\n"

wget -q https://archive.neon.kde.org/public.key -O neon.key
	printf "ee86878b3be00f5c99da50974ee7c5141a163d0e00fccb889398f1a33e112584 neon.key" | sha256sum -c &&
	apt-key add neon.key > /dev/null
	rm neon.key


# -- Use sources.list.build to build ISO.

cp /configs/sources.list /etc/apt/sources.list


# -- Update packages list and install packages. Install desktop packages.

printf "\n"
printf "INSTALLING DESKTOP."
printf "\n"

DESKTOP_PACKAGES='
neon-desktop
'

apt -qq update
apt -yy upgrade
apt -yy install ${DESKTOP_PACKAGES//\\n/ }


# -- Install the kernel.

printf "\n"
printf "INSTALLING KERNEL."
printf "\n"

kfiles='
https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15/linux-headers-4.15.0-041500_4.15.0-041500.201802011154_all.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15/linux-headers-4.15.0-041500-generic_4.15.0-041500.201802011154_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15/linux-image-4.15.0-041500-generic_4.15.0-041500.201802011154_amd64.deb
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
