free5GC-srsRAN
================

Patch of [free5GC stage1](https://bitbucket.org/nctu_5g/free5gc-stage-1/src/master/) to fix the session error as srsRAN/srsLTE connected

## Tested Environment
- OS: Ubuntu 20.04.3 LTS
- Linux kernel: 5.13.0-28-generic
- GCC 9.3.0
- Go 1.17.6
- MongoDB 3.6.9
- srsRAN 21.10 / srsLTE 20.04
- NodeJS 16.13.0

## Preparation

### Collect eNodeB and USIM Information

- The default configuration of srsENB 
```
IP Address: 127.0.1.1
PLMN:
  MCC: 001
  MNC: 01
MME GID:  1
MME Code: 26
TAC: 7
```

- The USIM configuration of srsUE (UE2)
```
IMSI 001010123456780
K    00112233445566778899AABBCCDDEEFF
OPc  63BFA50EE6523365FF14C1F45F88737D
```

## Automatically Installation
```bash
git clone https://github.com/nuk-icslab/free5GC-srsLTE.git
cd free5GC-srsLTE
bash ./install.sh
```

## Manualily Installation & Usage
### Install Dependency

```bash
sudo apt install -y mongodb golang nodejs npm autoconf libtool gcc pkg-config git flex bison libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev
go get -u -v "github.com/gorilla/mux"
go get -u -v "golang.org/x/net/http2"
go get -u -v "golang.org/x/sys/unix"
go env -w GO111MODULE=auto
```

### Add a TUN Device

```bash
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
```

### Compile Source Code

```bash
git clone https://github.com/nuk-icslab/free5GC-srsLTE.git
cd free5GC-srsLTE

git clone https://bitbucket.org/nctu_5g/free5gc-stage-1.git
cd free5gc-stage-1
git checkout e72022
git am ../patch/*
git log

autoreconf -iv
./configure
make -j `nproc`
sudo make install
```

### Update Certification

```bash
# Reference: https://github.com/acetcom/open5gs/issues/93
cd support/freeDiameter
./make_cert.sh .
```
### Add Subscriber

```
cd ../../webui/
npm install
npm run dev
```

Browse http://127.0.0.1:3000
```
username: admin
password: 1423
```

Then add a subscriber and save.
![](https://i.imgur.com/OZnZLJl.png)

### Setup Routing

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -A POSTROUTING -t nat -s 45.45.0.0/24 -o $OUT_IFACE -j MASQUERADE
```

### Launch

```bash
cd ../
sudo ./free5gc-ngcd -f free5gc-srslte.conf

#or

./nextepc-hssd -f free5gc-srslte.conf
./free5gc-upfd -f free5gc-srslte.conf
./free5gc-amfd -f free5gc-srslte.conf
./nextepc-pcrfd -f free5gc-srslte.conf
./free5gc-smfd -f free5gc-srslte.conf
```
And then you can start both srsenb and srsue directly.
![](https://i.imgur.com/geVdknm.png)
