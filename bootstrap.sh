#! /bin/bash


export LANG=C
export LC_ALL=C


# -- Packages to install.

PACKAGES='
dhcpcd5
user-setup
localechooser-data
cifs-utils
casper
lupin-casper
xz-utils
elementary-desktop
'


# -- Install basic packages.

apt -qq update > /dev/null
apt -yy -qq install apt-transport-https wget ca-certificates gnupg2 apt-utils sudo --no-install-recommends > /dev/null


# -- Add key for elementary repositories

	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E1F8A59 > /dev/null
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE70B91C > /dev/null


# -- Use sources.list.build to build ISO.

cp /configs/sources.list /etc/apt/sources.list


# -- Update packages list and install packages. Install Nomad Desktop meta package and base-files package avoiding recommended packages.

apt -qq update > /dev/null
apt -yy -qq upgrade > /dev/null
apt -yy -qq install ${PACKAGES//\\n/ } > /dev/null
apt -yy -qq purge --remove gnome-software > /dev/null

# -- Install the kernel.

printf "INSTALLING NEW KERNEL."

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

cp /configs/10-globally-managed-devices.conf /etc/NetworkManager/conf.d/


# -- Update the initramfs.

cp /configs/initramfs.conf /etc/initramfs-tools/

cat /configs/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
update-initramfs -u


# -- Clean the filesystem.

apt -yy -qq purge --remove casper lupin-casper > /dev/null
apt -yy -qq autoremove > /dev/null
apt -yy -qq clean > /dev/null
