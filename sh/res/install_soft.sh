#!/bin/bash

#flarumone
if [ ! -f flarumone.zip ];then
  wget ${cdn}/master/flarumone.zip
fi
rm -rf flarumone
mkdir -p flarumone
unzip flarumone.zip -d flarumone
mv flarumone /data1/www/flarumone

#phpmyadmin
if [ ! -f phpmyadmin.zip ];then
  wget ${cdn}/master/phpmyadmin.zip
fi
rm -rf phpmyadmin
unzip phpmyadmin.zip
mv phpmyadmin /data1/www/default/phpmyadmin
cd /data1/www/default

#default
cd /data1/www/default

#create index.html
cat > index.html << END
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="欢迎使用 FlarumOne 一键 LNMP 环境包">
    <meta name="author" content="flarumone">
    <title>FlarumOne 一键 LNMP 环境包</title>
    <!-- Bootstrap core CSS -->
    <link href="//cdn.bootcss.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom styles for this template -->
    <style>
        /* Sticky footer styles-------------------------------------------------- */
        html {
            position: relative;
            min-height: 100%;
        }
        body {
            /* Margin bottom by footer height */
            margin-bottom: 60px;
        }
        .footer {
            position: absolute;
            bottom: 0;
            width: 100%;
            /* Set the fixed height of the footer here */
            height: 60px;
            background-color: #f5f5f5;
        }


        /* Custom page CSS
        -------------------------------------------------- */
        /* Not required for template or sticky footer method. */

        .container {
            width: auto;
            max-width: 680px;
            padding: 0 15px;
        }
        .container .text-muted {
            margin: 20px 0;
        }</style>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
    <script src="//cdn.bootcss.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="//cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
<!-- Begin page content -->
<div class="container">
    <div class="page-header">
        <h1>欢迎使用 FlarumOne 一键 LNMP 环境包</h1>
        <h4>Welcome to FlarumOne LNMP a key environment Pack</h4>
    </div>
    <p>您服务器的 IP 地址是：<code>${serverIp}</code><br/>PHP信息页面：<code>http://${serverIp}/info.php</code><br/>PhpMyAdmin 的默认管理入口是：<code>http://${serverIp}/phpmyadmin</code><br/>FlarumOne的首页入口是您绑定的域名。 </p>
    <p>Your server's IP address is:<code>${serverIp}</code><br/>PHP info Page:<code>http://${serverIp}/info.php</code><br/>PhpMyAdmin default login is:<code>http://${serverIp}/phpmyadmin</code><br/>FlarumOne Home entrance that you bind the domain name.</p>
    <p>GitHub:<code>https://github.com/flarumone/lnmp</code></p>
</div>
<footer class="footer">
    <div class="container">
        <p class="text-muted">&copy; 2015 FlarumOne</p>
    </div>
</footer>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-25385240-9', 'auto');
  ga('send', 'pageview');

</script>
</body>
</html>
END

#create info.php
cat > info.php << END
<?php
phpinfo();
END

find ./ -type f | xargs chmod 644
find ./ -type d | xargs chmod 755

cd -

chown -R www:www /data1/www
