#!/bin/bash

####---- install dependencies ----begin####
if [ "$ifredhat" != "" ];then
  yum makecache
  yum -y install kernel-devel python
elif [ "$ifcentos" != "" ];then
  yum makecache
  yum -y install kernel-devel python
elif [ "$ifubuntu" != "" ];then
  apt-get -y update
  apt-get -y install python build-essential gcc g++
elif [ "$ifdebian" != "" ];then
  apt-get -y update
  apt-get -y install python build-essential gcc g++
fi
####---- install dependencies ----end####

####---- install Nodejs ----begin####

if [ ! -f node-v${nodejs_version}.tar.gz ];then
	wget ${cdn}/project/nodejs/node-v${nodejs_version}.tar.gz
fi
rm -rf node-v${nodejs_version}
tar -zxf node-v${nodejs_version}.tar.gz
cd node-v${nodejs_version}/
./configure --prefix=/data1/server/nodejs
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..
####---- install Nodejs ----end####

if [ "$ifsuse" != "" ];then
	echo 'export PATH=$PATH:/data1/server/nodejs/bin' >> /etc/profile.d/profile.sh
	source /etc/profile.d/profile.sh &> /dev/null
else
	echo 'export PATH=$PATH:/data1/server/nodejs/bin' >> /etc/profile
	source /etc/profile &> /dev/null
fi

####---- install npm ----begin####
curl -sS https://www.npmjs.com/install.sh | sh
npm install -g gulp

rm -rf composer.phar
curl -sS https://getcomposer.org/installer | /data1/server/php/bin/php
mv composer.phar /usr/local/bin/composer

if [ "$ifsuse" != "" ];then
	echo 'export PATH=$PATH:/usr/local/bin/composer:/root/.composer/vendor/bin' >> /etc/profile.d/profile.sh
	source /etc/profile.d/profile.sh &> /dev/null
else
	echo 'export PATH=$PATH:/usr/local/bin/composer:/root/.composer/vendor/bin' >> /etc/profile
	source /etc/profile &> /dev/null
fi
####---- install npm ----end####
