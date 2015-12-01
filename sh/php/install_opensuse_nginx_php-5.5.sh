#!/bin/bash
ln -s /usr/local/libpng.1.2.54/lib64/libpng.so  /usr/lib64/
ln -s  /usr/local/freetype.2.6.2/lib64/libfreetype.so /usr/lib64/
zypper install -y gd
rm -rf php-5.5.30
if [ ! -f php-5.5.30.tar.gz ];then
  wget ${cdn}/project/php/php-5.5.30.tar.gz
fi
tar zxvf php-5.5.30.tar.gz
cd php-5.5.30
./configure --prefix=/data1/server/php \
--enable-opcache \
--with-config-file-path=/data1/server/php/etc \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-fpm \
--enable-fastcgi \
--enable-static \
--enable-inline-optimization \
--enable-sockets \
--enable-wddx \
--enable-zip \
--enable-calendar \
--enable-bcmath \
--enable-soap \
--with-zlib \
--with-iconv \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--without-sqlite \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.2.6.2 \
--with-jpeg-dir=/usr/local/jpeg.6b \
--with-png-dir=/usr/local/libpng.1.2.54 \
--disable-ipv6 \
--disable-debug \
--with-openssl \
--disable-maintainer-zts \
--disable-safe-mode \
--enable-fileinfo

if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install
cd ..
cp ./php-5.5.30/php.ini-production /data1/server/php/etc/php.ini
#adjust php.ini
sed -i 's#; extension_dir = \"\.\/\"#extension_dir = "/data1/server/php/lib/php/extensions/no-debug-non-zts-20121212/"#'  /data1/server/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /data1/server/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /data1/server/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /data1/server/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /data1/server/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /data1/server/php/etc/php.ini
#adjust php-fpm
cp /data1/server/php/etc/php-fpm.conf.default /data1/server/php/etc/php-fpm.conf
sed -i 's,user = nobody,user=www,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,group = nobody,group=www,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,^pm.min_spare_servers = 1,pm.min_spare_servers = 5,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,^pm.max_spare_servers = 3,pm.max_spare_servers = 35,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,^pm.max_children = 5,pm.max_children = 100,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,^pm.start_servers = 2,pm.start_servers = 20,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid,pid = run/php-fpm.pid,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /data1/log/php/php-fpm.log,g'   /data1/server/php/etc/php-fpm.conf
sed -i 's,;slowlog = log/$pool.log.slow,slowlog = /data1/log/php/\$pool.log.slow,g'   /data1/server/php/etc/php-fpm.conf
#self start
install -v -m755 ./php-5.5.30/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm
/etc/init.d/php-fpm start
sleep 5
