# 欢迎使用 FlarumOne 一键 LNMP 环境包
#### Welcome to FlarumOne LNMP a key environment Pack

PhpMyAdmin 的默认管理入口是：`http://IP/phpmyadmin`  
FlarumOne 的首页入口是您绑定的域名。  
  
PhpMyAdmin default login is:`http://IP/phpmyadmin`
FlarumOne Home entrance that you bind the domain name.


### 参考命令
**安装**
```shell
wget http://res.szlt.net/master/lnmp.zip -P /tmp
cd /usr/local/src
unzip /tmp/lnmp.zip
chmod -R 777 sh && cd sh
./install.sh 2>&1 | tee install.log
```
**卸载**
```shell
cd /usr/local/src
./uninstall.sh 2>&1 | tee uninstall.log
```
**重新安装**
```shell
cd /usr/local/src
rm -rf sh
rm /tmp/lnmp.zip
wget http://res.szlt.net/master/lnmp.zip -P /tmp
unzip /tmp/lnmp.zip
chmod -R 777 sh && cd sh
./install.sh 2>&1 | tee install.log
```

### 常用管理命令
重启服务
```shell
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart
/etc/init.d/mysqld restart
```

### 帮助
如遇问题，可将安装日志` /usr/local/src/install.log `压缩成zip后发送到` support@flarumone.com `
也可以到** 求助 - LNMP **版块 https://flarumone.com/t/help-lnmp 发帖求助

### 案例分享
如果，您希望展示您的站点，也可把它发布到，我们的** 案例 - LNMP **中 https://flarumone.com/t/case-flarumone

谢谢大家的支持，么么哒