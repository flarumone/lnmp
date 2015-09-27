#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

# CPU_NUM
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

# Fix Version
fix_version=150927a
jpeg_version=v6b
libpng_version=1.2.53
freetype_version=2.1.10
old_jpeg_version=v9a
old_jpeg_version=${old_jpeg_version/a/}
old_libpng_version=1.6.18
old_freetype_version=2.6

clear
echo "+---------------------------------------------------------------------------+"
echo "|     Welcome to FlarumOne LNMP v0.1.0-Beta.1 PHP fix, version: ${fix_version}     |"
echo "+---------------------------------------------------------------------------+"
echo "|         For more information please visit https://flarunone.com           |"
echo "+---------------------------------------------------------------------------+"

# Check Version
if [ ! -d "/usr/local/jpeg.${old_jpeg_version/v/}" ] && [ ! -d "/usr/local/freetype.${old_freetype_version}" ] && [ ! -d "/usr/local/jpeg.${old_jpeg_version/v/}" ]; then
    echo "Error: Sorry, you are not an LNMP v0.1.0-Beta.1 user, if you need help, please go to https://flarumone.com/t/lnmp"
    exit 1
fi

# CDN
tmp=n
read -p "Please select your server in mainland China, input Y or N : " tmp
if [ "$tmp" == "y" ] || [ "$tmp" == "Y" ];then
  export isChina=yes
  tmp=1
  read -p "Please select a CDN node of SinaSAE/AliyunCDN, input 1 or 2 : " tmp
  if [ "$tmp" == "1" ];then
    cdnName=SinaSAE
    export cdn=https://api.sinas3.com/v1/SAE_gocc
  elif [ "$tmp" == "2" ];then
    cdnName=AliyunCDN
    export cdn=http://res.szlt.net
  fi
elif [ "$tmp" == "n" ] || [ "$tmp" == "N" ];then
  cdnName=AWSS3US
  export isChina=no
  export cdn=http://s3us.flarumone.com
fi

# Downgrade PNG
rm -rf /usr/local/libpng.${old_libpng_version}
if [ ! -f libpng-${libpng_version}.tar.gz ];then
    wget ${cdn}/project/libpng/libpng-${libpng_version}.tar.gz
fi
rm -rf libpng-${libpng_version}
tar zxvf libpng-${libpng_version}.tar.gz
cd libpng-${libpng_version}
./configure --prefix=/usr/local/libpng.${libpng_version}
if [ $CPU_NUM -gt 1 ];then
    make CFLAGS=-fpic -j$CPU_NUM
else
    make CFLAGS=-fpic
fi
make install
cd ..
echo "----------Downgrade PNG Finish!----------" >> tmp_fix_${fix_version}.log

# Downgrade Freetype
rm -rf /usr/local/freetype.${old_freetype_version}
if [ ! -f freetype-${freetype_version}.tar.gz ];then
    wget ${cdn}/project/freetype/freetype-${freetype_version}.tar.gz
fi
rm -rf freetype-${freetype_version}
tar zxvf freetype-${freetype_version}.tar.gz
cd freetype-${freetype_version}
./configure --prefix=/usr/local/freetype.${freetype_version}
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..
echo "----------Downgrade Freetype Finish!----------" >> tmp_fix_${fix_version}.log

# Downgrade Jpeg
rm -rf /usr/local/jpeg.${old_jpeg_version/v/}
if [ ! -f jpegsrc.${jpeg_version}.tar.gz ];then
    wget ${cdn}/project/jpegsrc/jpegsrc.${jpeg_version}.tar.gz
fi
rm -rf jpeg-${jpeg_version/v/}
tar zxvf jpegsrc.${jpeg_version}.tar.gz
cd jpeg-${jpeg_version/v/}
if [ -e /usr/share/libtool/config.guess ];then
    cp -f /usr/share/libtool/config.guess .
elif [ -e /usr/share/libtool/config/config.guess ];then
    cp -f /usr/share/libtool/config/config.guess .
fi
if [ -e /usr/share/libtool/config.sub ];then
    cp -f /usr/share/libtool/config.sub .
elif [ -e /usr/share/libtool/config/config.sub ];then
    cp -f /usr/share/libtool/config/config.sub .
fi
./configure --prefix=/usr/local/jpeg.6b --enable-shared --enable-static
mkdir -p /usr/local/jpeg.${jpeg_version/v/}/include
mkdir /usr/local/jpeg.${jpeg_version/v/}/lib
mkdir /usr/local/jpeg.${jpeg_version/v/}/bin
mkdir -p /usr/local/jpeg.${jpeg_version/v/}/man/man1
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install-lib
make install
cd ..
echo "----------Downgrade Jpeg Finish!----------" >> tmp_fix_${fix_version}.log

# Recompile PHP
rm -rf php-5.5.29
if [ ! -f php-5.5.29.tar.gz ];then
  wget ${cdn}/project/php/php-5.5.29.tar.gz
fi
tar zxvf php-5.5.29.tar.gz
cd php-5.5.29
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
--with-iconv=/usr/local \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--without-sqlite \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.${freetype_version} \
--with-jpeg-dir=/usr/local/jpeg.${jpeg_version/v/} \
--with-png-dir=/usr/local/libpng.${libpng_version} \
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
echo "----------Recompile PHP Finish!----------" >> tmp_fix_${fix_version}.log

# Restart PHP and Nginx
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

# Print Log
cat tmp_fix_${fix_version}.log