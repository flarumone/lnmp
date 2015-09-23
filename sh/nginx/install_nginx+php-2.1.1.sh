#!/bin/bash
rm -rf tengine-2.1.1
if [ ! -f tengine-2.1.1.tar.gz ];then
  wget ${cdn}/project/tengine/tengine-2.1.1.tar.gz
fi
tar zxvf tengine-2.1.1.tar.gz
cd tengine-2.1.1
./configure --user=www \
--group=www \
--prefix=/data1/server/nginx \
--with-http_sub_module=shared \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
chmod 775 /data1/server/nginx/logs
chown -R www:www /data1/server/nginx/logs
chmod -R 775 /data1/www
chown -R www:www /data1/www
cd ..
cp -fR ./nginx/config-nginx/* /data1/server/nginx/conf/
sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' /data1/server/nginx/conf/nginx.conf
sed -i 's/server_name	127.0.0.1/server_name	'"$serverIp"'/' /data1/server/nginx/conf/vhosts/default.conf
chmod 755 /data1/server/nginx/sbin/nginx
#/data1/server/nginx/sbin/nginx
mv /data1/server/nginx/conf/nginx /etc/init.d/
chmod +x /etc/init.d/nginx
/etc/init.d/nginx start
