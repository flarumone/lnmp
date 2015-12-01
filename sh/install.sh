#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

for app in $(find . -name "*.sh" -exec echo {} \;); do
	chmod +x ${app}
done

####---- global variables ----begin####
export nginx_version=2.1.1
export mysql_version=5.5.46
export php_version=5.5.30
export nodejs_version=0.12.7
export phpmyadmin_version=4.4.12
####---- global variables ----end####

install_log=/data1/website-info.log

####---- version selection ----begin####

LNMP_Ver='0.1.0-Beta.5'
clear
echo "+---------------------------------------------------------------------------+"
echo "|        LNMP V${LNMP_Ver} for Linux Server, Written by FlarumOne          |"
echo "+---------------------------------------------------------------------------+"
echo "| A tool to auto-compile & install Nginx+PHP+MySQL+NodeJS+Composer on Linux |"
echo "+---------------------------------------------------------------------------+"
echo "|         For more information please visit https://flarunone.com           |"
echo "+---------------------------------------------------------------------------+"

function CheckIPAddress()
{
  if [ `echo $1 | awk -F . '{print NF}'` -ne 4 ];then
    echo "wrong"
    exit 2
  else
    a=`echo $1 | awk -F . '{print $1}'`
    b=`echo $1 | awk -F . '{print $2}'`
    c=`echo $1 | awk -F . '{print $3}'`
    d=`echo $1 | awk -F . '{print $4}'`
    if [[ $a -gt 0 && $a -le 255 ]] && [[ $b -ge 0 && $b -le 255 ]] && [[ $c -ge 0 && $c -le 255 ]] && [[ $d -gt 0 && $d -lt 255 ]];then
      echo "right"
    else
      echo "wrong"
    fi
  fi
}

isIp=n
read -p "Enter server IP manually? This maybe useful when you are setting local develop environment up. input Y or N :" isIp
if [ "${isIp}" == "y" ] || [ "${isIp}" == "Y" ];then
  read -p "Please input IP for this server:" serverIp
  if [ "$(CheckIPAddress $serverIp)" == "wrong" ];then
    read -p "Wrong IP address, try again:" serverIp
    if [ "$(CheckIPAddress $serverIp)" == "wrong" ];then
      echo 'Too many errors, please try again.'
      exit 2
    else
      echo "Right!"
    fi
  else
    echo "Right!"
  fi
else
  serverIp=$(curl http://gocc.sinaapp.com/ip.php)
  if [ "$(CheckIPAddress $serverIp)" == "wrong" ];then
    read -p "Error when getting server ip, please input IP for this server:" serverIp
    if [ "$(CheckIPAddress $serverIp)" == "wrong" ];then
      read -p "Wrong IP address, try again:" serverIp
      if [ "$(CheckIPAddress $serverIp)" == "wrong" ];then
        echo 'Too many errors, please try again.'
        exit 2
      else
        echo "Right!"
      fi
    else
      echo "Right!"
    fi
  else
    echo "Right!"
  fi
fi

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

tmp=y
read -p "Please Select whether you want to install MySQL, input Y or N : " tmp
if [ "$tmp" == "y" ] || [ "$tmp" == "Y" ];then
  export isMysql=yes
  tmp=1
  read -p "Please select the mysql version of 5.5.46/5.6.27, input 1 or 2 : " tmp
  if [ "$tmp" == "1" ];then
    mysql_version=5.5.46
  elif [ "$tmp" == "2" ];then
    mysql_version=5.6.27
  fi
elif [ "$tmp" == "n" ] || [ "$tmp" == "N" ];then
  export isMysql=no
fi

tmp=n
read -p "Please Select whether you want to install NodeJS, input Y or N : " tmp
if [ "$tmp" == "y" ] || [ "$tmp" == "Y" ];then
  export isNodejs=yes
  tmp=1
  read -p "Please select the NodeJS version of 0.12.7/4.2.2, input 1 or 2 : " tmp
  if [ "$tmp" == "1" ];then
    nodejs_version=0.12.7
  elif [ "$tmp" == "2" ];then
    nodejs_version=4.2.2
  fi
elif [ "$tmp" == "n" ] || [ "$tmp" == "N" ];then
  export isNodejs=no
fi

echo ""
echo "You select the information :"
echo "Server IP : $serverIp"
echo "CDN : $cdnName"
if [ "${isMysql}" != "yes" ];then
  if [ "${isNodejs}" != "yes" ];then
  	echo "Nginx : $nginx_version"
  	echo "PHP : $php_version"
  else
	echo "Nginx : $nginx_version"
  	echo "PHP : $php_version"
  	echo "NodeJS : $nodejs_version"
  fi
else
  if [ "${isNodejs}" != "yes" ];then
	  echo "Nginx : $nginx_version"
	  echo "PHP : $php_version"
	  echo "mysql : $mysql_version"
    else
	  echo "Nginx : $nginx_version"
	  echo "PHP : $php_version"
	  echo "Mysql : $mysql_version"
  	  echo "NodeJS : $nodejs_version"
  fi
fi

read -p "Enter the y or Y to continue:" isY
if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
   exit 1
fi
####---- version selection ----end####

####---- Clean up the environment ----begin####
echo "will be installed, wait ..."
./uninstall.sh in &> /dev/null
####---- Clean up the environment ----end####

if [ `uname -m` == "x86_64" ];then
  export machine=x86_64
else
  export machine=i686
fi

####---- global variables ----begin####
export serverIp
export web_dir=nginx-${nginx_version}
export php_dir=php-${php_version}
export mysql_dir=mysql-${mysql_version}
export nodejs_dir=nodejs-${nodejs_version}
export CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
export ifredhat=$(cat /proc/version | grep redhat)
#export ifcentos=$(cat /proc/version | grep centos)
export ifcentos=$(cat /etc/issue | grep  -E "CentOS|Kernel")
export ifubuntu=$(cat /proc/version | grep ubuntu)
export ifdebian=$(cat /proc/version | grep -i debian)
export ifgentoo=$(cat /proc/version | grep -i gentoo)
export ifsuse=$(cat /proc/version | grep -i suse)
export if14=$(cat /etc/issue | grep 14)
####---- global variables ----end####

####---- install dependencies ----begin####
if [ "$ifcentos" != "" ] || [ "$machine" == "i686" ];then
rpm -e httpd-2.2.3-31.el5.centos gnome-user-share &> /dev/null
fi

\cp /etc/rc.local /etc/rc.local.bak > /dev/null
if [ "$ifredhat" != "" ];then
rpm -e --allmatches mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
fi

if [ "$ifredhat" != "" ];then
  \mv /etc/yum.repos.d/rhel-debuginfo.repo /etc/yum.repos.d/rhel-debuginfo.repo.bak &> /dev/null
  \cp ./res/rhel-debuginfo.repo /etc/yum.repos.d/
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip automake fiex* libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake libaio*
  iptables -F
elif [ "$ifcentos" != "" ];then
#	if grep 5.10 /etc/issue;then
	  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5 &> /dev/null
#	fi
  sed -i 's/^exclude/#exclude/' /etc/yum.conf
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++  make libtool autoconf patch unzip automake libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake libaio*
  yum -y update bash
  iptables -F
elif [ "$ifubuntu" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  apt-get -y install --only-upgrade bash
  iptables -F
elif [ "$ifdebian" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip psmisc build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  apt-get -y install --only-upgrade bash
  iptables -F
elif [ "$ifgentoo" != "" ];then
  emerge net-misc/curl
elif [ "$ifsuse" != "" ];then
  zypper install -y libxml2-devel libopenssl-devel libcurl-devel
fi
####---- install dependencies ----end####

####---- install software ----begin####
rm -f tmp.log
echo tmp.log

if [ -e /dev/xvdb ] && [ "$ifsuse" == "" ] ;then
	./env/install_disk.sh
fi

./env/install_dir.sh
echo "---------- make dir ok ----------" >> tmp.log

./env/install_set_sysctl.sh
./env/install_set_ulimit.sh
./env/install_env_php.sh
echo "---------- env ok ----------" >> tmp.log

if [ "$isMysql" == "yes" ];then
	./mysql/install_${mysql_dir%.*}.sh
	echo "---------- ${mysql_dir} ok ----------" >> tmp.log
fi

./nginx/install_nginx+php-${nginx_version}.sh
echo "---------- ${web_dir} ok ----------" >> tmp.log
if [ "$ifsuse" != "" ];then
	./php/install_opensuse_nginx_php-${php_version%.*}.sh
else
	./php/install_nginx_php-${php_version%.*}.sh
fi
echo "---------- ${php_dir} ok ----------" >> tmp.log

./php/install_php_extension.sh
echo "---------- php extension ok ----------" >> tmp.log

./res/install_soft.sh
echo "---------- phpmyadmin-${phpmyadmin_version} ok ----------" >> tmp.log
echo "---------- web init ok ----------" >> tmp.log

####---- install software ----end####


####---- Start command is written to the rc.local ----begin####
if [ "$ifgentoo" != "" ];then
	if [ "$isMysql" == "yes" ];then
		if ! cat /etc/local.d/sysctl.start | grep "/etc/init.d/mysqld" > /dev/null;then
			echo "/etc/init.d/mysqld start" >> /etc/local.d/sysctl.start
		fi
	fi
	if ! cat /etc/local.d/sysctl.start | grep "/etc/init.d/nginx" > /dev/null;then
		echo "/etc/init.d/nginx start" >> /etc/local.d/sysctl.start
	fi
	if ! cat /etc/local.d/sysctl.start |grep "/etc/init.d/php-fpm" > /dev/null;then
		echo "/etc/init.d/php-fpm start" >> /etc/local.d/sysctl.start
	fi

elif [ "$ifsuse" != "" ];then
	if [ "$isMysql" == "yes" ];then
 		if ! cat /etc/rc.d/boot.local | grep "/etc/init.d/mysqld" > /dev/null;then
			echo "/etc/init.d/mysqld start" >> /etc/rc.d/boot.local
		fi
	fi
	if ! cat /etc/rc.d/boot.local | grep "/etc/init.d/nginx" > /dev/null;then
		echo "/etc/init.d/nginx start" >> /etc/rc.d/boot.local
	fi
	if ! cat /etc/rc.d/boot.local |grep "/etc/init.d/php-fpm" > /dev/null;then
		echo "/etc/init.d/php-fpm start" >> /etc/rc.d/boot.local
	fi
else
	if [ "$isMysql" == "yes" ];then
		if ! cat /etc/rc.local | grep "/etc/init.d/mysqld" > /dev/null;then
			echo "/etc/init.d/mysqld start" >> /etc/rc.local
		fi
	fi
	if ! cat /etc/rc.local | grep "/etc/init.d/nginx" > /dev/null;then
		 echo "/etc/init.d/nginx start" >> /etc/rc.local
	fi
	if ! cat /etc/rc.local |grep "/etc/init.d/php-fpm" > /dev/null;then
		echo "/etc/init.d/php-fpm start" >> /etc/rc.local
	fi
fi
####---- Start command is written to the rc.local ----end####


####---- centos yum configuration----begin####
if [ "$ifcentos" != "" ] && [ "$machine" == "x86_64" ];then
sed -i 's/^#exclude/exclude/' /etc/yum.conf
fi
if [ "$ifubuntu" != "" ] || [ "$ifdebian" != "" ];then
	mkdir -p /var/lock
	sed -i 's#exit 0#touch /var/lock/local#' /etc/rc.local
else
	mkdir -p /var/lock/subsys/
fi
####---- centos yum configuration ----end####

if [ "$isMysql" == "yes" ];then
	####---- mysql password initialization ----begin####
	echo "---------- rc init ok ----------" >> tmp.log
	TMP_PASS=$(date | md5sum |head -c 10)
	/data1/server/mysql/bin/mysqladmin -u root password "$TMP_PASS"
	sed -i s/'mysql_password'/${TMP_PASS}/g account.log
	echo "---------- mysql init ok ----------" >> tmp.log
	####---- mysql password initialization ----end####
fi

####---- Environment variable settings ----begin####
if [ "$ifsuse" != "" ];then
	\cp /etc/profile.d/profile.sh /etc/profile.d/profile.sh.bak
	if [ "$isMysql" == "yes" ];then
		echo 'export PATH=$PATH:/data1/server/mysql/bin:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin' >> /etc/profile.d/profile.sh
		export PATH=$PATH:/data1/server/mysql/bin:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin
	else
		echo 'export PATH=$PATH:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin' >> /etc/profile.d/profile.sh
		export PATH=$PATH:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin
	fi
else
	\cp /etc/profile /etc/profile.bak
	if [ "$isMysql" == "yes" ];then
		echo 'export PATH=$PATH:/data1/server/mysql/bin:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin' >> /etc/profile
		export PATH=$PATH:/data1/server/mysql/bin:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin
	else
		echo 'export PATH=$PATH:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin' >> /etc/profile
		export PATH=$PATH:/data1/server/nginx/sbin:/data1/server/php/sbin:/data1/server/php/bin
	fi
fi
####---- Environment variable settings ----end####

####---- restart ----begin####
/etc/init.d/php-fpm restart &> /dev/null
/etc/init.d/nginx restart &> /dev/null
if [ "$isMysql" == "yes" ];then
	/etc/init.d/mysqld restart &> /dev/null
fi
####---- restart ----end####

####---- nodejs install ---begin####
if [ "$isNodejs" == "yes" ];then
	./nodejs/install_nodejs.sh
	echo "---------- ${nodejs_dir} ok ----------" >> tmp.log
fi
####---- nodejs install---end####

####---- openssl update---begin####
./env/update_openssl.sh
####---- openssl update---end####

####---- log ----begin####
cat account.log
\cp tmp.log $install_log
cat $install_log
source /etc/profile &> /dev/null
source /etc/profile.d/profile.sh &> /dev/null
####---- log ----end####
