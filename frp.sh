#!/bin/bash
cd /root
echo ' ________________________________________________________ '
echo '|  ______   _____    _____      _                     _  |'
echo '| |  ____| |  __ \  |  __ \    | |                   | | |'
echo '| | |__    | |__) | | |__) |   | |_    ___     ___   | | |'
echo '| |  __|   |  _  /  |  ___/    | __|  / _ \   / _ \  | | |'
echo '| | |      | | \ \  | |        | |_  | (_) | | (_) | | | |'
echo '| |_|      |_|  \_\ |_|         \__|  \___/   \___/  |_| |'
echo '|                                                        |' 
echo '|                                               By WIJ   |'
echo '|________________________________________________________|'  
echo '															'
until false 
do

echo "choose whitch frp platform you want to use"
echo "(1).frp for server"
echo "(2).frp for client"
echo "(3).quit"
read -p "請輸入選項(1-3):" platform

	install_frp ()
	{
		conf_file ()
	{
	case ${platform} in
1)
	server_conf_file='[common]
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
	log_file = /root/frp/frps.log
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
	tcp_mux = true'
echo "${server_conf_file}"
;;
2)
	client_conf_file="[common]
	# A literal address or host name for IPv6 must be enclosed
	server_addr = "${ip_address}"
	server_port = 7000

	# if you want to connect frps by http proxy, you can set http_proxy here or in global environment variables
	# it only works when protocol is tcp
	# http_proxy = http://user:pwd@192.168.1.128:8080

	# console or real logFile path like ./frpc.log
	log_file = /root/frp/frpc.log

	# trace, debug, info, warn, error
	log_level = info

	log_max_days = 3

	# for authentication
	privilege_token = rpLjPOgPWDiaZKDe

	# set admin address for control frpcs action by http api such as reload
	admin_addr = 127.0.0.1
	admin_port = 7400
	admin_user = king
	admin_pwd = Happydaygo4

	# connections will be established in advance, default value is zero
	pool_count = 5

	# if tcp stream multiplexing is used, default is true, it must be same with frps
	tcp_mux = true

	# decide if exit program when first login failed, otherwise continuous relogin to frps
	# default is true
	login_fail_exit = true

	# communication protocol used to connect to server
	# now it supports tcp and kcp, default is tcp
	protocol = tcp
	[range:tcp_port_02]
	type = tcp
	local_ip = 127.0.0.1
	local_port = 3389
	remote_port = 4000
	use_encryption = true
	use_compression = true
	"
echo "${client_conf_file}"
;;
esac

 }
	
	case ${platform} in
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
					if [ ${platform} -eq 1 ]; then
					conf_file > /root/frp/frps.ini
					wait
					else
					conf_file > /root/frp/frpc.ini
					wait
					fi
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
					if [ ${platform} -eq 1 ]; then
					conf_file > /root/frp/frps.ini
					wait
					else
					conf_file > /root/frp/frpc.ini
					wait
					fi
		fi
	;;
	2)
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
					conf_file > /root/frp/frpc.ini
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
				echo "${conf_file}" > /root/frp/frpc.ini
		fi
	;;
	esac
	}
	start_frp () 
	{
	case ${platform} in
	1)
		if [ -d "/root/frp" ]; then
		nohup="/usr/bin/nohup"
		${nohup} /root/frp/frps -c /root/frp/frps.ini  > /root/frp/nohup-frps.out 2>&1&
		echo "starting frps server"
		else
		echo "frp尚未安裝"
		fi
		;;
	2)
		if [ -d "/root/frp" ]; then
		nohup="/usr/bin/nohup"
		${nohup} /root/frp/frpc -c /root/frp/frpc.ini  > /root/frp/nohup-frpc.out 2>&1&
		echo "starting frpc server"
		else
		echo "frp尚未安裝"
		fi
		;;	
	esac
	}
	stop_frp () 
	{
	case ${platform} in
	1)
		if [ -f "/bin/killall" ]; then
		echo ""
		else
		yum install psmisc -y || apt-get install psmisc -y
		fi
		wait
		if [ "${frps_task}" = "frps" ]; then
		killall frps
		wait
		echo "frp server stop success"
		read -p "Press any key to continue." var
		clear
		else
		echo "frps尚未啟動"
		fi
		;;
	2)
		if [ -f "/bin/killall" ]; then
		echo ""
		else
		wait
		yum install psmisc -y || apt-get install psmisc -y
		fi
		if [ "${frpc_task}" = "frpc" ]; then
		killall frpc
		wait
		echo "frp client stop success"
		read -p "Press any key to continue." var
		clear
		else
		echo "frpc尚未啟動"
		fi
		;;
	esac
	}
	frp_boot_up ()
	{
	case ${platform} in
	1)
		if [ "${search_dash}" = "dash" ]; then
			sudo dpkg-reconfigure dash
			wait
			read -p "Press any key to continue." var
		else
			source /etc/os-release 
		case $ID in
		debian|ubuntu|devuan)
			mkdir -p /root/frp/
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
			echo "add success"
			echo "使用方式 systemctl (start|stop|status|restart|enable) frp.service"
				read -p "Press any key to continue." var
				clear
			
		;;
		esac
		fi
	;;
	2)
		if [ "${search_dash}" = "dash" ]; then
			sudo dpkg-reconfigure dash
			wait
			read -p "Press any key to continue." var
		else
			source /etc/os-release 
		case $ID in
		debian|ubuntu|devuan)
			touch /etc/init.d/frpc
			chmod 755 /etc/init.d/frpc
			touch /root/frp/frp-start.sh
			chmod +x /root/frp/frp-start.sh
			echo "nohup="/usr/bin/nohup"
			nohup ./root/frp/frpc -c /root/frp/frpc.ini &" > /root/frp/frp-start.sh
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
killall frpc
;;
restart)
			 
killall frpc
/bin/sh /root/frp/frp-start.sh
;;
esac
exit ' > /etc/init.d/frpc
			wait
			update-rc.d frpc defaults
			echo "Ubuntu添加開機自啟成功"
			echo "相關指令為service frpc (start|stop|restart)"
				read -p "Press any key to continue." var
				clear
		;;
		centos|fedora|rhel)
			touch /root/frp/frp-start.sh
				chmod +x /root/frp/frp-start.sh
				echo 'nohup="/usr/bin/nohup"
			nohup ./root/frp/frpc -c /root/frp/frpc.ini &' > /root/frp/frp-start.sh
				touch /etc/systemd/system/frp.service
				chmod 754 /etc/systemd/system/frp.service
				echo "[Unit]
			Description=FRP Service
			[Service]
			User=root
			Type=forking
			ExecStart=/usr/bin/sh /root/frp/frp-start.sh
			ExecStop=/usr/bin/killall frpc
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
	esac
	}
	edit_frp ()
	{ 
	case ${platform} in
	1)
		vim /root/frp/frps.ini
		wait
		if [ "${frps_task}" = "frps" ]; then
		killall frps
		wait
		nohup /root/frp/frps -c /root/frp/frps.ini &
		wait
		else
		continue
		fi
		;;
	2)
		vim /root/frp/frpc.ini
		wait
		if [ "${frps_task}" = "frps" ]; then
		killall frps
		wait
		nohup /root/frp/frpc -c /root/frp/frpc.ini &
		wait
		else
		continue
		fi		
		;;
	esac
	}	
	frp_log ()
	{
	
		frp_log="$(ls /root/frp/frp*.log)"
		if [ -f "${frp_log}" ]; then
		watch tail /root/frp/frp*.log
		else
		echo "尚未存在任何日誌"
		fi
	}
	uninstall_frp ()
	{
	
		if [ "${frps_task}" = "frps" ]; then
		killall frps 
		echo "frp server have been stop"
		elif [ "${frpc_task}" = "frpc" ]; then
		killall frpc
		echo "frp client have been stop"
		wait
		fi
		rm -rf /root/frp
		rm -rf /root/frp_0.16.0_linux_amd64.tar.gz
		rm -rf /etc/init.d/frps
		rm -rf /etc/init.d/frpc
		rm -rf /etc/systemd/system/frp.service
		echo "uninstall success"
		read -p "Press any key to continue." var
		clear
	}

	until false 
	do
	frps_task="$(ps -e | grep -o frps)"
	frpc_task="$(ps -e | grep -o frpc)"
	search_dash="$(ls -l /bin/sh | grep -o dash)"
case ${platform} in
1)
	echo "(1).安裝frp"
	echo "(2).啟動frp"
	echo "(3).停止frp"
	echo "(4).將frp加入開機啟動"
	echo "(5).編輯frp設定檔"
	echo "(6).查看frp log檔"
	echo "(7).解除安裝frp"
	echo "(8).離開"
	read -p "請輸入選項(1-8):" option
	case ${option} in
		1)
		install_frp 
		;;
		2)
		start_frp
		;;
		3)
		stop_frp
		;;
		4)
		frp_boot_up
		;;
		5)
		edit_frp
		;;
		6)
		frp_log
		;;
		7)
		uninstall_frp
		;;
		8)
			read -p "Press any key to continue." var
			clear
			break
		;;
		*)
			echo "輸入錯誤，請重新輸入一次"
			read -p "Press any key to continue." var
			clear
		;;
	esac
;;
2)
	echo "(1).安裝frp"
	echo "(2).啟動frp"
	echo "(3).停止frp"
	echo "(4).將frp加入開機啟動"
	echo "(5).編輯frp設定檔"
	echo "(6).查看frp log檔"
	echo "(7).解除安裝frp"
	echo "(8).離開"
	read -p "請輸入選項(1-8):" option
	case ${option} in
		1)
		read -p "請輸入frp server IP 位置 :" ip_address
		wait
		install_frp 
		;;
		2)
		start_frp
		;;
		3)
		stop_frp
		;;
		4)
		frp_boot_up
		;;
		5)
		edit_frp
		;;
		6)
		frp_log
		;;
		7)
		uninstall_frp
		;;
		8)
			read -p "Press any key to continue." var
			clear
			break
		;;
		*)
			echo "輸入錯誤，請重新輸入一次"
			read -p "Press any key to continue." var
			clear
		;;
	esac
;;
3)
	read -p "Press any key to continue." var
	clear
	exit
;;
*)
	clear
;;
esac
	done
done