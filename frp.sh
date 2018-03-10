#!/bin/bash
until false 
do
echo "(1).安裝frp"
echo "(2).啟動frp"
echo "(3).停止frp"
echo "(4).將frp加入開機啟動"
echo "(5).編輯frp設定檔"
echo "(6).解除安裝frp"
echo "(7).離開"
read -p "請輸入選項(1-7):" option
case ${option} in
	1)
	echo "檢查使否已安裝frp..."
		if [ -d "/root/frp" ]; then
			echo "已安裝frp"
			echo "是否要重新安裝?"
			echo "(1).Yes (2).No"
			read -p "請輸入(1-2):" decide
				case ${decide} in
				1)
					killall frps || echo "frps have been stop"
					wait
					rm -rf /root/frp
					rm -rf /etc/init.d/frps
					rm -rf /etc/systemd/system/frp.service
					wait
					echo "uninstall success"
					echo "reinstalling..."
					wget -P /root https://github.com/fatedier/frp/releases/download/v0.16.0/frp_0.16.0_linux_amd64.tar.gz
					wait
					tar -zxvf  /root/frp_0.16.0_linux_amd64.tar.gz
					wait
					mv /root/frp_0.16.0_linux_amd64 /root/frp
					wait
					rm -rf /root/frp_0.16.0_linux_amd64.tar.gz
					wait
					echo '[common]
					# A literal address or host name for IPv6 must be enclosed
					# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
					bind_addr = 0.0.0.0
					bind_port = 7000
					# udp port used for kcp protocol, it can be same with bind_port
					# if not set, kcp is disabled in frps
					kcp_bind_port = 7000
					# if you want to configure or reload frps by dashboard, dashboard_port must be set
					dashboard_port = 7500
					# dashboard assets directory(only for debug mode)
					dashboard_user = king
					dashboard_pwd = Happydaygo4
					# assets_dir = ./static

					vhost_http_port = 8080
					vhost_https_port = 443
					# console or real logFile path like ./frps.log
					log_file = ./frps.log
					# debug, info, warn, error
					log_level = info
					log_max_days = 3
					# privilege mode is the only supported mode since v0.10.0
					privilege_token = rpLjPOgPWDiaZKDe
					# only allow frpc to bind ports you list, if you set nothing, there wont be any limit
					#privilege_allow_ports = 1-65535
					# pool_count in each proxy will change to max_pool_count if they exceed the maximum value
					max_pool_count = 50
					# if tcp stream multiplexing is used, default is true
					tcp_mux = true' > /root/frp/frps.ini
					wait
					echo "reinstall success"
					read -p "Press any key to continue." var
					clear
					;;
				2)
					continue
					clear
					
					;;
					esac
		else
				echo "安裝中..."
				wget -P /root https://github.com/fatedier/frp/releases/download/v0.16.0/frp_0.16.0_linux_amd64.tar.gz
				wait
				tar -zxvf  /root/frp_0.16.0_linux_amd64.tar.gz
				wait
				mv /root/frp_0.16.0_linux_amd64 /root/frp
				wait
				rm -rf /root/frp_0.16.0_linux_amd64.tar.gz
				wait
				echo '[common]
				# A literal address or host name for IPv6 must be enclosed
				# in square brackets, as in "[::1]:80", "[ipv6-host]:http" or "[ipv6-host%zone]:80"
				bind_addr = 0.0.0.0
				bind_port = 7000
				# udp port used for kcp protocol, it can be same with bind_port
				# if not set, kcp is disabled in frps
				kcp_bind_port = 7000
				# if you want to configure or reload frps by dashboard, dashboard_port must be set
				dashboard_port = 7500
				# dashboard assets directory(only for debug mode)
				dashboard_user = king
				dashboard_pwd = Happydaygo4
				# assets_dir = ./static

				vhost_http_port = 8080
				vhost_https_port = 443
				# console or real logFile path like ./frps.log
				log_file = ./frps.log
				# debug, info, warn, error
				log_level = info
				log_max_days = 3
				# privilege mode is the only supported mode since v0.10.0
				privilege_token = rpLjPOgPWDiaZKDe
				# only allow frpc to bind ports you list, if you set nothing, there wont be any limit
				#privilege_allow_ports = 1-65535
				# pool_count in each proxy will change to max_pool_count if they exceed the maximum value
				max_pool_count = 50
				# if tcp stream multiplexing is used, default is true
				tcp_mux = true' > /root/frp/frps.ini
				fi
	;;
	2)
 nohup="/usr/bin/nohup"
 ${nohup} /root/frp/frps -c /root/frp/frps.ini &
 echo "starting frp server"
	;;
	3)
	killall frps
	wait
	read -p "Press any key to continue." var
	clear
	;;
	4)
search_dash="$(ls -l /bin/sh | grep -o dash)"
if [ "${search_dash}" = "dash" ]; then
	sudo dpkg-reconfigure dash
	wait
	read -p "Press any key to continue." var
else
	source /etc/os-release 
case $ID in
debian|ubuntu|devuan)
touch /etc/init.d/frps
chmod 755 /etc/init.d/frps
touch /root/frp/frp-start.sh
chmod +x /root/frp/frp-start.sh
echo "nohup="/usr/bin/nohup"
nohup ./root/frp/frps -c /root/frp/frps.ini &" > /root/frp/frp-start.sh
echo '#!/bin/sh
### BEGIN INIT INFO
# Provides: frp
# Required-Start: $remote_fs $network
# Required-Stop: $remote_fs $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: frp nettool
### END INIT INFO
 
case "$1" in
start)
 
 echo -n "starting frp"
/bin/sh /root/frp/frp-start.sh

;;
stop)
 
 echo -n "stoping frp"
 killall frps
;;
restart)
 
 killall frps
/bin/sh /root/frp/frp-start.sh
;;
esac
exit ' > /etc/init.d/frps
wait
update-rc.d frps defaults
echo "Ubuntu添加開機自啟成功"
echo "相關指令為service frps (start|stop|restart)"
	read -p "Press any key to continue." var
	clear
    ;;
centos|fedora|rhel)
touch /root/frp/frp-start.sh
	chmod +x /root/frp/frp-start.sh
	echo 'nohup="/usr/bin/nohup"
nohup ./root/frp/frps -c /root/frp/frps.ini &' > /root/frp/frp-start.sh
	touch /etc/systemd/system/frp.service
	chmod 754 /etc/systemd/system/frp.service
	echo "[Unit]
Description=FRP Service
[Service]
User=root
Type=forking
ExecStart=/usr/bin/sh /root/frp/frp-start.sh
ExecStop=/usr/bin/killall frps
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/frp.service
wait
echo "使用方式 systemctl (start|stop|status|restart|enable) frp.service"
	read -p "Press any key to continue." var
	clear
	
    ;;
esac
fi
	;;
	5)
	vim /root/frp/frps.ini
	wait
	killall frps
	wait
	nohup /root/frp/frps -c /root/frp/frps.ini &
	wait
	;;
	6)
	killall frps || echo "frps have been stop"
	wait
	rm -rf /root/frp
	rm -rf /root/frp_0.16.0_linux_amd64.tar.gz
	rm -rf /etc/init.d/frps
	rm -rf /etc/systemd/system/frp.service
	echo "uninstall success"
	read -p "Press any key to continue." var
	clear
	;;
	7)
	read -p "Press any key to continue." var
	clear
	break
	;;
esac
done