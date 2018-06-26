#!/bin/sh

sudo apt-get install libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool
TMP=$(mktemp -d --suffix=NSENTER_TMP)
wget https://www.kernel.org/pub/linux/utils/util-linux/v2.30/util-linux-2.30.2.tar.gz -qO - | tar -xz -C $TMP/
cd $TMP/util-linux-2.30.2 && ./autogen.sh && ./configure && make nsenter
mkdir -p $HOME/.local/bin
sudo cp -v $TMP/util-linux-2.30.2/nsenter $HOME/.local/bin/nsenter
sudo chmod +x $HOME/.local/bin/nsenter
sudo cp -v $HOME/.local/bin/nsenter /usr/bin/nsenter