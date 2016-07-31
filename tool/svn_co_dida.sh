#!/usr/bin/env bash

clear
version=v0.1.0-Beta.1
echo "+---------------------------------------------------------------------------+"
echo "|     Welcome to use Dida to build a key script, version: ${version}     |"
echo "+---------------------------------------------------------------------------+"
echo "|         For more information please visit https://flarunone.com           |"
echo "+---------------------------------------------------------------------------+"

IsInstallSVN=Y
read -p "Have SVN been installed? Enter the Y or N to continue:" IsInstallSVN
if [ "${IsInstallSVN}" != "y" ] && [ "${IsInstallSVN}" != "Y" ];then
  echo -e "Please install SVN and try again \n apt-get install subversion | yum install subversion \nGoodbye!"
  exit 1
fi

rm -rf dida
mkdir dida
cd dida

if [ ! -d 'core' ];then
    mkdir core
fi
svn co svn://didaah.org/dida/trunk dida

if [ ! -d 'modules' ];then
    mkdir modules
fi
cd modules
for modules in article banned comment content domain editor forum google_chart highcharts mall message og page pchart phpExcel solr solr_stats test voteapi weibo; do
  if [ ! -d ${modules} ];then
    mkdir ${modules}
  fi
  svn co svn://didaah.org/sites/modules/${modules}/trunk ${modules}
done
cd ..

if [ ! -d 'themes' ];then
    mkdir themes
fi
cd themes
for themes in rover; do
  if [ ! -d ${themes} ];then
    mkdir ${themes}
  fi
  svn co svn://didaah.org/sites/themes/${themes}/trunk ${themes}
done
cd ..

mkdir dida-release
cd dida-release
cp -rf ../dida/* .
cp -rf ../modules sites
cp -rf ../themes sites
find . -name ".svn" -type d | xargs rm -fr
# Finally, create the release archive
find . -type d -exec chmod 0750 {} +
find . -type f -exec chmod 0644 {} +
chmod 0775 .
chmod -R 0775 sites/logs sites/default/cache sites/default/files
cd ..
tar czf dida-release.tar.gz dida-release
ls -l
echo 'Build success!'
