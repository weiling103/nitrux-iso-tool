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
apt -yy -qq install apt-transport-https wget ca-certificates gnupg2 apt-utils --no-install-recommends > /dev/null


# -- Add key for elementary repositories

	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E1F8A59 > /dev/null


# -- Use sources.list.build to build ISO.

cp /configs/sources.list /etc/apt/sources.list


# -- Update packages list and install packages. Install Nomad Desktop meta package and base-files package avoiding recommended packages.

apt -qq update > /dev/null
apt -yy -qq upgrade > /dev/null
apt -yy install ${PACKAGES//\\n/ }
apt install -f


# -- Add znx.

APPS_SYS='
https://github.com/Nitrux/znx/releases/download/continuous-development/znx_development
'

mkdir /Applications

for x in $APPS_SYS; do
	wget -q -P /Applications $x
done

chmod +x /Applications/*
mkdir -p /etc/skel/Applications

chmod +x /etc/skel/Applications/*
mv /Applications/znx_development /Applications/znx

# -- Add znx-gui.

cp /configs/znx-gui.desktop /usr/share/applications
wget -q -O /bin/znx-gui https://raw.githubusercontent.com/Nitrux/nitrux-iso-tool/development/configs/znx-gui
chmod +x /bin/znx-gui


# -- Add config for SDDM.
# -- Add fix for https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1638842.
# -- Add kservice menu item for Dolphin for AppImageUpdate.
# -- Add custom launchers for Maui apps.
# -- Add policykit file for KDialog.

cp /configs/10-globally-managed-devices.conf /etc/NetworkManager/conf.d/


# -- Update the initramfs.

cat /configs/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
update-initramfs -u


# -- Clean the filesystem.

apt -yy -qq purge --remove casper lupin-casper > /dev/null
apt -yy -qq autoremove > /dev/null
apt -yy -qq clean > /dev/null
