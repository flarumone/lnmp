#!/bin/bash

#imagemagick
if [ ! -f ImageMagick-6.9.2-7.tar.gz ];then
	wget ${cdn}/project/imagemagick/ImageMagick-6.9.2-7.tar.gz
fi
rm -rf ImageMagick-6.9.2-7
tar -xzvf ImageMagick-6.9.2-7.tar.gz
cd ImageMagick-6.9.2-7
./configure --prefix=/usr/local/imagemagick-6.9.2-7
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..

#imagick
if [ ! -f imagick-3.1.2.tgz ];then
	wget ${cdn}/project/imagick/imagick-3.1.2.tgz
fi
rm -rf imagick-3.1.2
tar -xzvf imagick-3.1.2.tgz
cd imagick-3.1.2
/data1/server/php/bin/phpize
./configure --with-php-config=/data1/server/php/bin/php-config --with-imagick=/usr/local/imagemagick-6.9.2-7
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..
echo "extension=imagick.so" >> /data1/server/php/etc/php.ini

#memcache
if [ ! -f memcache-2.2.7.tgz ];then
	wget ${cdn}/project/memcache/memcache-2.2.7.tgz
fi
rm -rf memcache-2.2.7
tar -xzvf memcache-2.2.7.tgz
cd memcache-2.2.7
/data1/server/php/bin/phpize
./configure --enable-memcache --with-php-config=/data1/server/php/bin/php-config
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..
echo "extension=memcache.so" >> /data1/server/php/etc/php.ini

#zend
mkdir -p /data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/
if [ $machine == "x86_64" ];then
	wget ${cdn}/project/zendloader/zend-loader-php5.5-linux-x86_64.tar.gz
	tar zxvf zend-loader-php5.5-linux-x86_64.tar.gz
	mv ./zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so /data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/
else
    wget ${cdn}/project/zendloader/zend-loader-php5.5-linux-i386.tar.gz
	tar zxvf zend-loader-php5.5-linux-i386.tar.gz
	mv ./zend-loader-php5.5-linux-i386/ZendGuardLoader.so /data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/
fi
echo "zend_extension=/data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/ZendGuardLoader.so" >> /data1/server/php/etc/php.ini
echo "zend_loader.enable=1" >> /data1/server/php/etc/php.ini
echo "zend_loader.disable_licensing=0" >> /data1/server/php/etc/php.ini
echo "zend_loader.obfuscation_level_support=3" >> /data1/server/php/etc/php.ini
echo "zend_loader.license_path=" >> /data1/server/php/etc/php.ini
sed -i 's#\[opcache\]#\[opcache\]\nzend_extension=opcache.so#' /data1/server/php/etc/php.ini
sed -i 's#;opcache.enable=0#opcache.enable=1#' /data1/server/php/etc/php.ini

#opensuse_memcache
if [ "$ifsuse" != "" ];then
	ln -s /data1/server/php/lib64/extensions/no-debug-non-zts-20100525/memcache.so  /data1/server/php/lib/php/extensions/no-debug-non-zts-20100525/memcache.so
	ln -s /data1/server/php/lib64/extensions/no-debug-non-zts-20121212/*  /data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/
fi
