#!/bin/bash -ex

apt-get update
apt-get install python-mysqldb -y

echo "#### CAU HINH FILE MY.CNF ####"
sleep 3

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sed -i "/bind-address/a\default-storage-engine = innodb\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/mysql/my.cnf
#
service mysql restart

echo "#### DONE ####"
