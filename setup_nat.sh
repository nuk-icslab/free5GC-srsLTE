#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: ./setup_nat.sh {outgoing interface}"
	exit 2
fi

sudo ip link set uptun up
sudo ip addr add 45.45.0.1/24 dev uptun
echo "Enabling ip forward..."
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -D POSTROUTING -s 45.45.0.0/24 -o $1 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 45.45.0.0/24 -o $1 -j MASQUERADE
sudo iptables -t nat -L POSTROUTING -v
