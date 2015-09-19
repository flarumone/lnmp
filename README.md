#欢迎使用 FlarumOne 一键 LNMP 环境包
####Welcome to FlarumOne LNMP a key environment Pack

PhpMyAdmin 的默认管理入口是：`http://IP/phpmyadmin`  
FlarumOne 的首页入口是您绑定的域名。  
  
PhpMyAdmin default login is:`http://IP/phpmyadmin`
FlarumOne Home entrance that you bind the domain name.


###参考安装命令
```shell
wget http://res.szlt.net/project/lnmp/lnmp.zip -P /tmp
cd /usr/local/src
unzip /tmp/lnmp.zip
chmod -R 777 sh && cd sh
./install.sh 2>&1 | tee install.log
```

###常用管理命令
重启服务
```shell
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart
/etc/init.d/mysqld restart
```
