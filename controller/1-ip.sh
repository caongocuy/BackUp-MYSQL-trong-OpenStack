#!/bin/bash -ex

source config.cfg

ifaces=/etc/network/interfaces
test -f $ifaces.orig || cp $ifaces $ifaces.orig
rm $ifaces

cat << EOF >> $ifaces

# Dat ip cho master1

# LOOPBACK NET
auto lo
iface lo inet loopback

# MNGT NETWORK
auto eth0
iface eth0 inet static
address $DB1_MGNT_IP
netmask $NETMASK_ADD_VM

# EXT NETWORK
auto eth1
iface eth1 inet static
address $DB1_EXT_IP
netmask $NETMASK_ADD
gateway $GATEWAY_IP
dns-nameservers 8.8.8.8
EOF

echo "#### Cau hinh hostname cho master1 ####"
sleep 3
echo "master1" > /etc/hostname
hostname -F /etc/hostname

# Khoi dong lai cac card mang vua dat
init 6
#
