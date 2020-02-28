#! /bin/bash

set -x

printf "\n"
printf "STARTING BOOTSTRAP."
printf "\n"


# -- Install basic packages.

printf "\n"
printf "INSTALLING BASIC PACKAGES."
printf "\n"

BASIC_PACKAGES='
apt-transport-https
apt-utils
ca-certificates
casper
dhcpcd5
fuse
gnupg2
ipxe-qemu
language-pack-en
language-pack-en-base
libarchive13
libelf1
localechooser-data
locales
lupin-casper
network-manager
ovmf
seabios
systemd-sysv
user-setup
wget
xz-utils
'

apt update &> /dev/null
apt -yy install ${BASIC_PACKAGES//\\n/ } --no-install-recommends


# -- Add key for our repository.
# -- Add key for the Proprietary Graphics Drivers PPA.

printf "\n"
printf "ADD REPOSITORY KEYS."
printf "\n"

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1B69B2DA > /dev/null
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1118213C > /dev/null


# -- Use sources.list.focal to install fuse3 and glib.
#FIXME We need to provide these packages from a repository of ours.

cp /configs/files/sources.list.focal /etc/apt/sources.list

printf "\n"
printf "INSTALLING FUSE3 AND GLIB."
printf "\n"

UPDATE_LIBC_FUSE3='
fuse3
gcc-10-base
libc-bin
libc-dev-bin
libc6
libc6-dev
libfuse3-3
libgcc-s1
libgcc1
linux-libc-dev
locales
'

apt update &> /dev/null
apt download ${UPDATE_LIBC_FUSE3//\\n/ } --no-install-recommends
dpkg --force-all -i *.deb
rm *.deb
apt clean &> /dev/null
apt autoclean &> /dev/null


# -- Use sources.list.build to build ISO.

cp /configs/files/sources.list.build /etc/apt/sources.list


# -- Update packages list and install packages.

printf "\n"
printf "INSTALLING DESKTOP."
printf "\n"

DESKTOP_PACKAGES='
nitrux-minimal
nitrux-standard
nitrux-hardware-drivers-minimal
'

apt update &> /dev/null
apt -yy --fix-broken install
apt -yy upgrade
apt -yy install ${DESKTOP_PACKAGES//\\n/ } --no-install-recommends
apt -yy --fix-broken install &> /dev/null
apt -yy purge --remove vlc &> /dev/null
apt -yy dist-upgrade


# -- Use sources.list.focal to update packages and install brew.

printf "\n"
printf "UPDATE MISC. PACKAGES."
printf "\n"

cp /configs/files/sources.list.eoan /etc/apt/sources.list

ADD_BREW_PACKAGES='
libc-dev-bin
libc6-dev
linux-libc-dev
linuxbrew-wrapper
'

apt update &> /dev/null
apt -yy install ${ADD_BREW_PACKAGES//\\n/ } --no-install-recommends
apt clean &> /dev/null
apt autoclean &> /dev/null


cp /configs/files/sources.list.focal /etc/apt/sources.list

UPGRADE_OS_PACKAGES='
amd64-microcode
broadcom-sta-dkms
dkms
exfat-fuse
exfat-utils
firejail
firejail-profiles
go-mtpfs
grub-common
grub-efi-amd64-bin
grub-efi-amd64-signed
grub2-common
i965-va-driver
initramfs-tools
initramfs-tools-bin
initramfs-tools-core
ipxe-qemu
libc6
libdrm-amdgpu1
libdrm-intel1
libdrm-radeon1
libva-drm2
libva-glx2
libva-x11-2
libva2
linux-firmware
mesa-va-drivers
mesa-vdpau-drivers
mesa-vulkan-drivers
openssh-client
openssl
ovmf
seabios
sudo
thunderbolt-tools
x11-session-utils
xinit
xserver-xorg
xserver-xorg-core
xserver-xorg-input-evdev
xserver-xorg-input-libinput
xserver-xorg-input-mouse
xserver-xorg-input-synaptics
xserver-xorg-input-wacom
xserver-xorg-video-amdgpu
xserver-xorg-video-intel
xserver-xorg-video-qxl
xserver-xorg-video-radeon
xserver-xorg-video-vmware
'

apt update &> /dev/null
apt -yy install ${UPGRADE_OS_PACKAGES//\\n/ } --only-upgrade --no-install-recommends
apt -yy --fix-broken install
apt clean &> /dev/null
apt autoclean &> /dev/null


# -- No apt usage past this point. -- #


# -- Install the kernel.
#FIXME This should be put in our repository.

printf "\n"
printf "INSTALLING KERNEL."
printf "\n"

kfiles='
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.21/linux-headers-5.4.21-050421_5.4.21-050421.202002191431_all.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.21/linux-headers-5.4.21-050421-generic_5.4.21-050421.202002191431_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.21/linux-image-unsigned-5.4.21-050421-generic_5.4.21-050421.202002191431_amd64.deb
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.21/linux-modules-5.4.21-050421-generic_5.4.21-050421.202002191431_amd64.deb
'

mkdir /latest_kernel

for x in $kfiles; do
printf "$x"
    wget -q -P /latest_kernel $x
done

dpkg -iR /latest_kernel &> /dev/null
dpkg --configure -a &> /dev/null
rm -r /latest_kernel


# -- Add missing firmware modules.
#FIXME These files should be included in a package.

printf "\n"
printf "ADDING MISSING FIRMWARE."
printf "\n"

fw='
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/vega20_ta.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/bxt_huc_ver01_8_2893.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/raven_kicker_rlc.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_asd.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_ce.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_gpu_info.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_me.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_mec.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_mec2.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_pfp.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_rlc.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_sdma.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_sdma1.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_smc.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_sos.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/navi10_vcn.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_asd.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_ce.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_gpu_info.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_me.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_mec.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_mec2.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_pfp.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_rlc.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_sdma.bin
https://raw.githubusercontent.com/UriHerrera/storage/master/Files/renoir_vcn.bin
'

mkdir /fw_files

for x in $fw; do
    wget -q -P /fw_files $x
done

cp /fw_files/{vega20_ta.bin,raven_kicker_rlc.bin,navi10_*.bin,renoir_*.bin} /lib/firmware/amdgpu/
cp /fw_files/bxt_huc_ver01_8_2893.bin /lib/firmware/i915/

rm -r /fw_files

ls -l /lib/firmware/amdgpu/


# -- Add /Applications to $PATH.

printf "\n"
printf "ADD /APPLICATIONS TO PATH."
printf "\n"

printf "PATH=$PATH:/Applications\n" > /etc/environment
sed -i "s|secure_path\=.*$|secure_path=\"$PATH:/Applications\"|g" /etc/sudoers
sed -i "/env_reset/d" /etc/sudoers


# -- Add system AppImages.
# -- Create /Applications directory for users.
# -- Rename AppImageUpdate, appimage-user-tool and znx.

printf "\n"
printf "ADD APPIMAGES."
printf "\n"

APPS_SYS='
https://github.com/Nitrux/znx/releases/download/continuous-master/znx-master-x86_64.AppImage
https://raw.githubusercontent.com/UriHerrera/storage/master/AppImages/appimage-cli-tool-x86_64.AppImage
https://raw.githubusercontent.com/UriHerrera/storage/master/AppImages/pnx-1.0.0-x86_64.AppImage
https://raw.githubusercontent.com/UriHerrera/storage/master/Binaries/vmetal-free-amd64
'

mkdir /Applications

for x in $APPS_SYS; do
    wget -q -P /Applications $x
done

chmod +x /Applications/*

mv /Applications/znx-master-x86_64.AppImage /Applications/znx
mv /Applications/appimage-cli-tool-x86_64.AppImage /Applications/app
mv /Applications/pnx-1.0.0-x86_64.AppImage /Applications/pnx
mv /Applications/vmetal-free-amd64 /Applications/vmetal

ls -l /Applications


# -- Add AppImage providers for appimage-cli-tool

printf "\n"
printf "ADD APPIMAGE PROVIDERS."
printf "\n"

cp /configs/files/appimage-providers.yaml /etc/


# -- Add fix for https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1638842.

printf "\n"
printf "ADD MISC. FIXES."
printf "\n"

cp /configs/files/10-globally-managed-devices.conf /etc/NetworkManager/conf.d/


# -- Workarounds for PNX.
#FIXME These need to be fixed in PNX.

printf "\n"
printf "ADD WORKAROUNDS FOR PNX."
printf "\n"

mkdir -p /var/lib/pacman/
mkdir -p /etc/pacman.d/
mkdir -p /usr/share/pacman/keyrings

cp /configs/files/pacman.conf /etc
cp /configs/files/mirrorlist /etc/pacman.d
cp /configs/other/pacman/* /usr/share/pacman/keyrings

ln -sv /home/.pnx/usr/lib/dri /usr/lib/dri
ln -sv /home/.pnx/usr/lib/pulseaudio /usr/lib/pulseaudio
ln -sv /home/.pnx/usr/lib/gdk-pixbuf-2.0 /usr/lib/gdk-pixbuf-2.0
ln -sv /home/.pnx/usr/lib/gs-plugins-13 /usr/lib/gs-plugins-13
ln -sv /home/.pnx/usr/lib/liblmdb.so /usr/lib/liblmdb.so
ln -sv /home/.pnx/usr/lib/systemd /usr/lib/systemd
ln -sv /home/.pnx/usr/lib/samba /usr/lib/samba
ln -sv /home/.pnx/usr/lib/girepository-1.0 /usr/lib/girepository-1.0
ln -sv /home/.pnx/usr/share/tracker /usr/share/tracker
ln -sv /home/.pnx/usr/lib/tracker-2.0 /usr/lib/tracker-2.0
ln -sv /home/.pnx/usr/lib/WebKitNetworkProcess /usr/lib/WebKitNetworkProcess
ln -sv /home/.pnx/usr/lib/epiphany /usr/lib/epiphany
ln -sv /home/.pnx/usr/lib/opera /usr/lib/opera
ln -sv /home/.pnx/usr/lib/firefox /usr/lib/firefox


# -- Add vfio modules and files.
#FIXME This configuration should be included a in a package; replacing the default package like base-files.

printf "\n"
printf "ADD VFIO ENABLEMENT AND CONFIGURATION."
printf "\n"

echo "install vfio-pci /bin/vfio-pci-override-vga.sh" >> /etc/initramfs-tools/modules
echo "install vfio_pci /bin/vfio-pci-override-vga.sh" >> /etc/initramfs-tools/modules
echo "softdep nvidia pre: vfio vfio_pci" >> /etc/initramfs-tools/modules
echo "softdep amdgpu pre: vfio vfio_pci" >> /etc/initramfs-tools/modules
echo "softdep radeon pre: vfio vfio_pci" >> /etc/initramfs-tools/modules
echo "softdep i915 pre: vfio vfio_pci" >> /etc/initramfs-tools/modules
echo "vfio" >> /etc/initramfs-tools/modules
echo "vfio_iommu_type1" >> /etc/initramfs-tools/modules
echo "vfio_virqfd" >> /etc/initramfs-tools/modules
echo "options vfio_pci ids=" >> /etc/initramfs-tools/modules
echo "vfio_pci ids=" >> /etc/initramfs-tools/modules
echo "vfio_pci" >> /etc/initramfs-tools/modules
echo "nvidia" >> /etc/initramfs-tools/modules
echo "amdgpu" >> /etc/initramfs-tools/modules
echo "radeon" >> /etc/initramfs-tools/modules
echo "i915" >> /etc/initramfs-tools/modules

echo "vfio" >> /etc/modules
echo "vfio_iommu_type1" >> /etc/modules
echo "vfio_pci" >> /etc/modules
echo "vfio_pci ids=" >> /etc/modules

cp /configs/files/asound.conf /etc/
cp /configs/files/asound.conf /etc/skel/.asoundrc
cp /configs/files/iommu_unsafe_interrupts.conf /etc/modprobe.d/
cp /configs/files/{amdgpu.conf,i915.conf,kvm.conf,nvidia.conf,qemu-system-x86.conf,radeon.conf,vfio_pci.conf,vfio-pci.conf} /etc/modprobe.d/
cp /configs/scripts/{vfio-pci-override-vga.sh,dummy.sh} /bin/

chmod +x /bin/dummy.sh


# -- Add oh my zsh.
#FIXME This should be put in a package.

printf "\n"
printf "ADD OH MY ZSH."
printf "\n"

git clone https://github.com/robbyrussell/oh-my-zsh.git /etc/skel/.oh-my-zsh


# -- Remove dash and use mksh as /bin/sh.
# -- Use zsh as default shell for all users.
#FIXME This should be put in a package.

printf "\n"
printf "REMOVE DASH AND USE MKSH + ZSH."
printf "\n"

rm /bin/sh.distrib
/usr/bin/dpkg --remove --no-triggers --force-remove-essential --force-bad-path dash &> /dev/null
ln -sv /bin/mksh /bin/sh
/usr/bin/dpkg --remove --no-triggers --force-remove-essential --force-bad-path dash &> /dev/null

sed -i 's+SHELL=/bin/sh+SHELL=/bin/zsh+g' /etc/default/useradd
sed -i 's+DSHELL=/bin/bash+DSHELL=/bin/zsh+g' /etc/adduser.conf


# -- Decrease timeout for systemd start and stop services.
#FIXME This should be put in a package.

printf "\n"
printf "DECREASE TIMEOUT FOR SYSTEMD SERVICES."
printf "\n"

sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=5s/g' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/g' /etc/systemd/system.conf


# -- Disable systemd services not deemed necessary.
# -- use 'mask' to fully disable them.

printf "\n"
printf "DISABLE SYSTEMD SERVICES."
printf "\n"

systemctl mask avahi-daemon.service
systemctl disable cupsd.service cupsd-browsed.service NetworkManager-wait-online.service keyboard-setup.service


# -- Fix for broken udev rules (yes, it is broken by default).
#FIXME This should be put in a package.

sed -i 's/ACTION!="add", GOTO="libmtp_rules_end"/ACTION!="bind", ACTION!="add", GOTO="libmtp_rules_end"/g' /lib/udev/rules.d/69-libmtp.rules


# -- Use sources.list.nitrux for release.

/bin/cp /configs/files/sources.list.nitrux /etc/apt/sources.list


# -- Remove APT.
#FIXME This should be put in a package.

printf "\n"
printf "REMOVE APT."
printf "\n"

REMOVE_APT='
apt 
apt-utils 
apt-transport-https
'

/usr/bin/dpkg --remove --no-triggers --force-remove-essential --force-bad-path ${REMOVE_APT//\\n/ } &> /dev/null


# -- Strip kernel modules.
# -- Use GZIP compression when creating the initramfs.
# -- Add initramfs hook script.
# -- Add the persistence and update the initramfs.
# -- Add znx_dev_uuid parameter.
#FIXME This should be put in a package.

printf "\n"
printf "UPDATE INITRAMFS."
printf "\n"

find /lib/modules/5.4.21-050421-generic/ -iname "*.ko" -exec strip --strip-unneeded {} \;
cp /configs/files/initramfs.conf /etc/initramfs-tools/
cp /configs/scripts/hook-scripts.sh /usr/share/initramfs-tools/hooks/
cat /configs/scripts/persistence >> /usr/share/initramfs-tools/scripts/casper-bottom/05mountpoints_lupin
# cp /configs/scripts/iso_scanner /usr/share/initramfs-tools/scripts/casper-premount/20iso_scan

update-initramfs -u
lsinitramfs /boot/initrd.img-5.4.21-050421-generic | grep vfio

rm /bin/dummy.sh


# -- Clean the filesystem.

printf "\n"
printf "REMOVE CASPER."
printf "\n"

REMOVE_PACKAGES='
casper
lupin-casper
'

/usr/bin/dpkg --remove --no-triggers --force-remove-essential --force-bad-path ${REMOVE_PACKAGES//\\n/ } &> /dev/null


# -- No dpkg usage past this point. -- #


# -- Use script to remove dpkg.

printf "\n"
printf "REMOVE DPKG."
printf "\n"

/configs/scripts/./rm-dpkg.sh
rm /configs/scripts/rm-dpkg.sh


printf "\n"
printf "EXITING BOOTSTRAP."
printf "\n"
