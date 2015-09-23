#!/bin/bash

if [ "$1" != "in" ];then
	echo "Before cleaning the installation script environment !"
	echo "Please backup your data !!"
	read -p "Enter the y or Y to continue:" isY
	if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
	   exit 1
	fi
fi

mkdir -p /data1
if which mkfs.ext4 > /dev/null ;then
	if ls /dev/xvdb1 &> /dev/null;then
	   if cat /etc/fstab|grep /data1 > /dev/null ;then
			if cat /etc/fstab|grep /data1|grep ext3 > /dev/null ;then
				sed -i "/\/data1/d" /etc/fstab
			fi
	   else
			echo '/dev/xvdb1             /data1                 ext4    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	fi
else
	if ls /dev/xvdb1 &> /dev/null;then
	   if cat /etc/fstab|grep /data1 > /dev/null ;then
			echo ""
	   else
			echo '/dev/xvdb1             /data1                 ext3    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	fi
fi

/etc/init.d/mysqld stop &> /dev/null
/etc/init.d/nginx stop &> /dev/null
/etc/init.d/php-fpm stop &> /dev/null
killall mysqld &> /dev/null
killall nginx &> /dev/null
killall php-fpm &> /dev/null

echo "--------> Clean up the installation environment"
rm -rf /usr/local/freetype.2.6
rm -rf /usr/local/libpng.1.6.18
rm -rf /usr/local/jpeg.9

echo ""
echo "--------> Delete directory"
echo "/data1/server/mysql             delete ok!" 
rm -rf /data1/server/mysql
echo "rm -rf /data1/server/mysql-*    delete ok!"
rm -rf /data1/server/mysql-*
echo "/data1/server/php               delete ok!"
rm -rf /data1/server/php
echo "/data1/server/php-*             delete ok!"
rm -rf /data1/server/php-*
echo "/data1/server/nginx             delete ok!"
rm -rf /data1/server/nginx
echo "rm -rf /data1/server/nginx-*    delete ok!"
rm -rf /data1/server/nginx-*
echo "/data1/server/nodejs            delete ok!"
rm -rf /data1/server/nodejs
echo "rm -rf /data1/server/nodejs-*   delete ok!"
rm -rf /data1/server/nodejs-*

echo ""
echo "/data1/log/php                  delete ok!"
rm -rf /data1/log/php
echo "/data1/log/mysql                delete ok!"
rm -rf /data1/log/mysql
echo "/data1/log/nginx                delete ok!"
rm -rf /data1/log/nginx
echo ""
echo "/data1/www/default              delete ok!"
rm -rf /data1/www/default

echo ""
echo "--------> Delete file"
echo "/etc/my.cnf                delete ok!"
rm -f /etc/my.cnf
echo "/etc/init.d/mysqld         delete ok!"
rm -f /etc/init.d/mysqld
echo "/etc/init.d/nginx          delete ok!"
rm -f /etc/init.d/nginx
echo "/etc/init.d/php-fpm        delete ok!"
rm -r /etc/init.d/php-fpm

echo ""
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifcentos=$(cat /proc/version | grep centos)
echo "--------> Clean up files"
echo "/etc/rc.local                   clean ok!"
if [ "$ifrpm" != "" ];then
	if [ -L /etc/rc.local ];then
		echo ""
	else
		\cp /etc/rc.local /etc/rc.local.bak
		rm -rf /etc/rc.local
		ln -s /etc/rc.d/rc.local /etc/rc.local
	fi
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.d/rc.local
else
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.local
fi

echo ""
echo "/etc/profile                    clean ok!"
sed -i "/export PATH=\$PATH\:\/data1\/server\/mysql\/bin.*/d" /etc/profile
source /etc/profile
