#!/bin/bash

mkdir -p /data1

if which mkfs.ext4 > /dev/null ;then
    ######
	if ls /dev/xvdb1 > /dev/null;then
	   if cat /etc/fstab|grep /data1 > /dev/null ;then
			if cat /etc/fstab|grep /data1|grep ext3 > /dev/null ;then
				sed -i "/\/data1/d" /etc/fstab
				echo '/dev/xvdb1             /data1                 ext4    defaults        0 0' >> /etc/fstab
			fi
	   else
			echo '/dev/xvdb1             /data1                 ext4    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	   echo ""
	   exit;
	else
		if ls /dev/xvdb ;then
fdisk /dev/xvdb << EOF
n
p
1


wq
EOF
			mkfs.ext4 /dev/xvdb1
			echo '/dev/xvdb1             /data1                 ext4    defaults        0 0' >> /etc/fstab
		fi
	fi
	######
else
	############
	if ls /dev/xvdb1 > /dev/null;then
	   if cat /etc/fstab|grep /data1 > /dev/null ;then
			echo ""
	   else
			echo '/dev/xvdb1             /data1                 ext3    defaults        0 0' >> /etc/fstab
	   fi
	   mount -a
	   echo ""
	   exit;
	else
		if ls /dev/xvdb ;then
fdisk /dev/xvdb << EOF
n
p
1


wq
EOF
			mkfs.ext3 /dev/xvdb1
			echo '/dev/xvdb1             /data1                 ext3    defaults        0 0' >> /etc/fstab
		fi
	fi
	############
fi

mount -a
echo "---------- add disk ok ----------" >> tmp.log