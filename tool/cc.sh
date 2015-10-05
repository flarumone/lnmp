#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root user"
    exit 1
fi

# Variables
version=v0.1.0-Beta.1

echo "+---------------------------------------------------------------------------+"
echo "|       Welcome to Flarum Clear Cache script, version: ${version}        |"
echo "+---------------------------------------------------------------------------+"
echo "|         For more information please visit https://flarunone.com           |"
echo "+---------------------------------------------------------------------------+"

# Check Flarum Path
read -p "Please input your Flarum Path, Default /data1/www/flarumone or input : " foPath
foPath=${foPath:-'/data1/www/flarumone'}
if [ ! -d "${foPath}/assets" ]; then
    echo "Error: Sorry, you are not an Flarum user, if you need help, please go to https://flarumone.com/t/lnmp"
    exit 1
fi

# Clear Cache
for app in js json css ; do
    rm "${foPath}"/assets/*."${app}"
done
rm -rf "${foPath}"/flarum/storage/framework/cache/*
rm "${foPath}"/flarum/storage/framework/views/*
rm "${foPath}"/flarum/storage/less/*
chown -R www:www "${foPath}"
echo "Cache Clear OK!"
