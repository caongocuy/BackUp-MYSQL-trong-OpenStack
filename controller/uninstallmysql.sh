#!/bin/bash -ex
#
echo "#### BAT DAU REMOVE MYSQL ####"
sleep 3
apt-get remove --purge mysql-server mysql-client mysql-common
apt-get autoremove
apt-get autoclean

echo "#### XOA THU MUC CUA MYSQL ####"
sleep 3
rm -rf /var/lib/mysql

echo "#### DONE ####"
sleep 3
echo "#### KHOI DONG LAI MAY ####"
init 6
#
