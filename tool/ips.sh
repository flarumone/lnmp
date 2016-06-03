# 从 nginx 日志里提取攻击者 IP（条件：1、agent 中包含百度，2、1 秒内访问超过10次），并写入到 ips.sh 脚本中
# 执行脚本，将 ip 加入到屏蔽列表 /data1/logs/nginx/ips.sh

tail -n 100000 /data1/logs/nginx/access.log |awk '{print $1,$12}' |grep -i -E ";\+Baiduspider\/2.0;\+\+" |awk '{print $1}'|sort|uniq -c|sort -rn |awk '{if($1>10)print "/sbin/iptables -D INPUT -s "$2" -j DROP\n/sbin/iptables -I INPUT -s "$2" -j DROP"}' > /data1/logs/nginx/ips.sh
