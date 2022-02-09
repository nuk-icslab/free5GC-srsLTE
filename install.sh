#!/bin/bash

# Install dependency
sudo apt install -y mongodb golang nodejs npm autoconf libtool gcc pkg-config git flex bison libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev
go get -u -v "github.com/gorilla/mux"
go get -u -v "golang.org/x/net/http2"
go get -u -v "golang.org/x/sys/unix"
go env -w GO111MODULE=auto

# Add TUN device
sudo sh -c "cat << EOF > /etc/systemd/network/99-free5gc.netdev
[NetDev]
Name=uptun
Kind=tun
EOF"

sudo sh -c "cat << EOF > /etc/systemd/network/99-free5gc.network
[Match]
Name=uptun
[Network]
Address=45.45.0.1/16
EOF"

sudo systemctl enable systemd-networkd
sudo systemctl restart systemd-networkd

# Download source code of Free5GC-Stage-1
git clone https://bitbucket.org/nctu_5g/free5gc-stage-1.git
cd free5gc-stage-1
git checkout e72022

# Patching
git am ../patch/*

# Compiling
autoreconf -iv
./configure
make -j `nproc`

# Update certification
cd support/freeDiameter
./make_certs.sh .
cd ../..

# Install
sudo make install
echo Installation was completed.
