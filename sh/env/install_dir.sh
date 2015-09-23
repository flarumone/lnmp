#!/bin/bash

userdel www
groupadd www
if [ "$ifubuntu" != "" ];then
useradd -g www -M -d /data1/www -s /usr/sbin/nologin www &> /dev/null
else
useradd -g www -M -d /data1/www -s /sbin/nologin www &> /dev/null
fi

mkdir -p /data1
mkdir -p /data1/server
mkdir -p /data1/www
mkdir -p /data1/log
mkdir -p /data1/log/php
mkdir -p /data1/log/nginx
mkdir -p /data1/log/nginx/access
mkdir -p /data1/server/${web_dir}
if [ "$isMysql" == "yes" ];then
	mkdir -p /data1/log/mysql
	mkdir -p /data1/server/${mysql_dir}
	ln -s /data1/server/${mysql_dir} /data1/server/mysql
fi
ln -s /data1/server/${web_dir} /data1/server/nginx
mkdir -p /data1/server/${php_dir}
ln -s /data1/server/${php_dir} /data1/server/php
if [ "$isNodejs" == "yes" ];then
	mkdir -p /data1/server/${nodejs_dir}
	ln -s /data1/server/${nodejs_dir} /data1/server/nodejs
fi
mkdir -p /data1/www/default
chown -R www:www /data1/log





