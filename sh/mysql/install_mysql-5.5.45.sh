#!/bin/bash

if [ $isChina == "yes" ];then
mysqlCDN=${cdn}/project/mysql
else
mysqlCDN=http://cdn.mysql.com/Downloads/MySQL-5.5
fi

if [ $machine == "x86_64" ];then
  rm -rf mysql-5.5.45-linux2.6-x86_64
  if [ ! -f mysql-5.5.45-linux2.6-x86_64.tar.gz ];then
	 wget ${mysqlCDN}/mysql-5.5.45-linux2.6-x86_64.tar.gz
  fi
  tar -xzvf mysql-5.5.45-linux2.6-x86_64.tar.gz
  mv mysql-5.5.45-linux2.6-x86_64/* /data1/server/mysql
else
  rm -rf mysql-5.5.45-linux2.6-i686
  if [ ! -f mysql-5.5.45-linux2.6-i686.tar.gz ];then
    wget ${mysqlCDN}/mysql-5.5.45-linux2.6-i686.tar.gz
  fi
  tar -xzvf mysql-5.5.45-linux2.6-i686.tar.gz
  mv mysql-5.5.45-linux2.6-i686/* /data1/server/mysql
fi

if [ "$ifubuntu" != "" ] && [ "$if14" != "" ];then
	mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
fi

groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
/data1/server/mysql/scripts/mysql_install_db --datadir=/data1/server/mysql/data/ --basedir=/data1/server/mysql --user=mysql
chown -R mysql:mysql /data1/server/mysql/
chown -R mysql:mysql /data1/server/mysql/data/
chown -R mysql:mysql /data1/log/mysql
\cp -f /data1/server/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/data1/server/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/data1/server/mysql/data#' /etc/init.d/mysqld
\cp -f /data1/server/mysql/support-files/my-medium.cnf /etc/my.cnf
echo "expire_logs_days = 5" >> /etc/my.cnf
echo "max_binlog_size = 1000M" >> /etc/my.cnf
sed -i 's#skip-external-locking#skip-external-locking\nlog-error=/data1/log/mysql/error.log#' /etc/my.cnf
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start
