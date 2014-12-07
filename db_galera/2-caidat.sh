#!/bin/bash -ex
#
source config.cfg

echo "#### Update he thong ####"
sleep 3
apt-get update && apt-get -y upgrade

echo "#### TAI MYSQL-WSREP VA GALERA ####"
sleep 3
wget https://launchpad.net/codership-mysql/5.6/5.6.16-25.5/+download/mysql-server-wsrep-5.6.16-25.5-amd64.deb
sleep 3
wget https://launchpad.net/galera/3.x/25.3.5/+download/galera-25.3.5-amd64.deb

echo "#### BAT DAU CAI DAT ####"
sleep 3
dpkg -i *.deb
sleep 3

echo "#### CAI GOI BO XUNG VA CAI DAT LAI ####"
sleep 3
apt-get -f install -y
sleep 3
dpkg -i *.deb
sleep 3

echo "#### TAO FILE VA PHAN QUYEN CHO THU MUC LOG ####"
mkdir -p /var/log/mysql && chown -R mysql. /var/log/mysql

echo "#### KHOI DONG MYSQL ####"
/etc/init.d/mysql start

echo "#### DANG NHAP MYSQL VA PHAN QUYEN ####"
sleep 3

cat << EOF | mysql -uroot
DELETE FROM mysql.user WHERE user='';
GRANT USAGE ON *.* TO root@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT USAGE ON *.* TO root@'localhost' IDENTIFIED BY '$MYSQL_PASS';
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_PASS') WHERE User='root';
FLUSH PRIVILEGES;
EOF

echo "#### CAU HINH CLUSTER ####"
sleep 3
filewsrep=/etc/mysql/conf.d/wsrep.cnf
test -f $filewsrep.orig || cp $filewsrep $filewsrep.orig
rm $filewsrep
touch $filewsrep

# CHEN NOI DUNG VAO FILE /etc/mysql/conf.d/wsrep.cnf

cat << EOF > $filewsrep
[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
innodb_locks_unsafe_for_binlog=1
query_cache_size=0
query_cache_type=0
bind-address=0.0.0.0
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_name="my_wsrep_cluster"
wsrep_cluster_address="gcomm://$DB1_EXT_IP"
wsrep_node_address=$DB2_EXT_IP
wsrep_slave_threads=1
wsrep_certify_nonPK=1
wsrep_max_ws_rows=131072
wsrep_max_ws_size=1073741824
wsrep_debug=0
wsrep_convert_LOCK_to_trx=0
wsrep_retry_autocommit=1
wsrep_auto_increment_control=1
wsrep_drupal_282555_workaround=0
wsrep_causal_reads=0
wsrep_notify_cmd=
wsrep_sst_method=rsync
wsrep_sst_auth=root:
EOF

echo "#### KHOI DONG LAI MYSQL ####"
sleep 3
service mysql restart

echo "#### SANG NODE MASTER1 SUA FILE CAU HINH ####"
sleep 3
#
