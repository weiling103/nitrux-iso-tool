#! /bin/sh

# -- Exit on errors.

set -xe

# -- Update xorriso and grub.

xorriso='
http://mirrors.kernel.org/ubuntu/pool/universe/libi/libisoburn/xorriso_1.5.0-1build1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/universe/libi/libisoburn/libisoburn1_1.5.0-1build1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/universe/libb/libburn/libburn4_1.5.0-1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/universe/libi/libisofs/libisofs6_1.5.0-1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/r/readline/libreadline8_8.0-1_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/r/readline/readline-common_8.0-1_all.deb
http://mirrors.kernel.org/ubuntu/pool/main/n/ncurses/libtinfo6_6.1+20181013-2ubuntu2_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/g/grub2/grub-efi-amd64-bin_2.02-2ubuntu8_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/g/grub2/grub-common_2.02-2ubuntu8_amd64.deb
http://mirrors.kernel.org/ubuntu/pool/main/g/grub2/grub2-common_2.02-2ubuntu8_amd64.deb
'

mkdir /latest_xorriso

for x in $xorriso; do
printf "$x"
    wget -q -P /latest_xorriso $x
done

dpkg -iR /latest_xorriso/
dpkg --configure -a
rm -r /latest_xorriso


# -- Prepare the directories for the build.

BUILD_DIR=$(mktemp -d)
ISO_DIR=$(mktemp -d)
OUTPUT_DIR=$(mktemp -d)

CONFIG_DIR=$PWD/configs


# -- The name of the ISO image.

IMAGE=nitrux-$(printf $TRAVIS_BRANCH | sed 's/master/stable/')-amd64.iso


# -- Prepare the directory where the filesystem will be created.

wget -O base.tar.gz -q http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.3-base-amd64.tar.gz
tar xf base.tar.gz -C $BUILD_DIR


# -- Populate $BUILD_DIR.

wget -qO /bin/runch https://raw.githubusercontent.com/Nitrux/tools/master/runch
chmod +x /bin/runch

cp -r configs $BUILD_DIR/

runch $BUILD_DIR -s bootstrap.sh || true

rm -rf $BUILD_DIR/configs


# -- Copy the kernel and initramfs to $ISO_DIR.

mkdir -p $ISO_DIR/boot

cp $(echo $BUILD_DIR/vmlinuz* | tr ' ' '\n' | sort | tail -n 1) $ISO_DIR/boot/kernel
cp $(echo $BUILD_DIR/initrd* | tr ' ' '\n' | sort | tail -n 1) $ISO_DIR/boot/initramfs


# -- Compress the root filesystem.

(while :; do sleep 300; printf "."; done) &

mkdir -p $ISO_DIR/casper
mksquashfs $BUILD_DIR $ISO_DIR/casper/filesystem.squashfs -comp gzip -no-progress -b 16384


# -- Generate the ISO image.

wget -qO /bin/mkiso https://raw.githubusercontent.com/Nitrux/tools/grub-bios/mkiso
chmod +x /bin/mkiso

git clone https://github.com/Nitrux/nitrux-grub-theme grub-theme

mkiso \
	-b \
	-V "NITRUX" \
	-g $CONFIG_DIR/files/grub.cfg \
	-g $CONFIG_DIR/files/loopback.cfg \
	-t grub-theme/nitrux \
	$ISO_DIR $OUTPUT_DIR/$IMAGE


# -- Calculate the checksum.

md5sum $OUTPUT_DIR/$IMAGE > $OUTPUT_DIR/${IMAGE%.iso}.md5sum


# -- Upload the ISO image.

cd $OUTPUT_DIR

export SSHPASS=$DEPLOY_PASS

for f in *; do
    sshpass -e scp -q -o stricthostkeychecking=no $f $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH
done
