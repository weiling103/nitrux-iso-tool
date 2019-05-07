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

# -- Install the kernel.

printf "INSTALLING NEW KERNEL."

kfiles='
http://mirrors.kernel.org/ubuntu/pool/main/l/linux-firmware/linux-firmware_1.173.5_all.deb
http://mirrors.kernel.org/ubuntu/pool/main/l/linux-signed/linux-image-4.15.0-48-generic_4.15.0-48.51_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/l/linux/linux-modules-4.15.0-48-generic_4.15.0-48.51_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/l/linux/linux-modules-extra-4.15.0-48-generic_4.15.0-48.51_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/a/amd64-microcode/amd64-microcode_3.20180524.1~ubuntu0.18.04.2_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/i/intel-microcode/intel-microcode_3.20180807a.0ubuntu0.18.04.1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/i/iucode-tool/iucode-tool_2.3.1-1_amd64.deb
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

cat /configs/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
update-initramfs -u


# -- Clean the filesystem.

apt -yy -qq purge --remove casper lupin-casper > /dev/null
apt -yy -qq autoremove > /dev/null
apt -yy -qq clean > /dev/null
