# 欢迎使用 FlarumOne 一键 LNMP 环境包
#### Welcome to FlarumOne LNMP a key environment Pack

PhpMyAdmin 的默认管理入口是：`http://IP/phpmyadmin`  
FlarumOne 的首页入口是您绑定的域名。  
  
PhpMyAdmin default login is:`http://IP/phpmyadmin`  
FlarumOne Home entrance that you bind the domain name.

### 安装菜单说明
名称 | 注释 | 可选值 | 默认 | 备注
-----|-----|--------|-----|-----
`Please select your server in mainland China` | 选择服务器是否在中国大陆 | `y/n` | `n` | 默认值`n`讲直接引用`AWS S3 US`亚马逊S3美国镜像，如果选`y`将进入**国内`CDN`节点选择**子菜单
`Please select a CDN node of SinaSAE/AliyunCDN` | 国内`CDN`节点选择 | `1/2` | `1` | 默认值`1`是新浪的SAE存储节点，`2`是阿里云的CDN节点
`Please Select whether you want to install MySQL` | 是否安装`MySQL`数据库 | `y/n` | `y` | 默认安装`MySQL`并进入**`MySQL`版本选择**子菜单，你也可选择`n`不安装
`Please select the mysql version of 5.5.46/5.6.27` | `MySQL`版本选择 | `1/2` | `1` | 默认安装`MySQL 5.5.46`，你也可以选择`2`以安装`MySQL 5.6.27`
`Please Select whether you want to install NodeJS` | 是否安装`NodeJS` | `y/n` | `n` | 默认不安装，如果选择`y`讲进入**`NodeJS`版本选择**子菜单
`Please select the NodeJS version of 0.12.7/4.2.2` | `NodeJS`版本选择 | `1/2` | `1` | 默认安装`NodeJS 0.12.7`，你也可以选择`2`以安装`NodeJS 4.2.2`

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

### 目录结构：
```
/data1
├── log                                          #各服务的日志全放这里
│   ├── mysql
│   ├── nginx
│   └── php
├── server                                       #各服务的编译文件全放这里
│   ├── mysql -> /data1/server/mysql-5.6.27      #这是个软链
│   ├── mysql-5.6.27                             #这是实体文件夹
│   ├── nginx -> /data1/server/nginx-2.1.1
│   ├── nginx-2.1.1
│   ├── nodejs -> /data1/server/nodejs-4.2.2
│   ├── nodejs-4.2.2
│   ├── php -> /data1/server/php-5.5.30
│   └── php-5.5.30
└── www                                          #各网站的文件全放这里
    ├── default
    └── flarumone
```

Nginx 配置文件路径：
```
/data1/server/nginx/conf
├── nginx.conf              #默认加载的配置文件，下面这些配置文件均从这里被调用
├── rewrite                 #存放 rewrite 规则，即伪静态规则
│   ├── default.conf
│   └── flarum.conf
└── vhosts                  #存放虚拟主机的配置文件，新加网站的配置文件统一存放于此
    ├── default.conf
    └── flarumone.conf
```

PHP 配置文件路径：
```
/data1/server/php/etc
├── pear.conf
├── php-fpm.conf
├── php-fpm.conf.default
└── php.ini
```

MySQL 配置文件路径：
```
/etc/my.cnf
```

### 帮助
如遇问题，可将安装日志` /usr/local/src/sh/install.log `压缩成zip后发送到` support@flarumone.com `
也可以到 https://flarumone.com/t/help 发帖求助

### 案例分享
如果，您希望展示您的站点，也可把它发布到，我们的 https://flarumone.com/t/case 中

谢谢大家的支持，么么哒