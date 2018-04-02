#!/bin/bash
until false
do
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

some_setting ()
{
frp_path="/root/frp"
Install_Path="/root"
kill_task_frps="$(killall frps)"
kill_task_frpc="$(killall frpc)"
frps_task="$(ps -e | grep -o frps)"
frpc_task="$(ps -e | grep -o frpc)"
search_dash="$(ls -l /bin/sh | grep -o dash)"
systemctl="$(ls /bin/systemctl)"
}

Ask_answer ()
{
read -p "please input your server IP :" Server_IP
read -p "add dashboard user :" User
read -p "input user password :" Password
read -p "input http Virtual host Port:" Vhost_http_port
read -p "input https Virtual host Port:" Vhost_https_port
}

systemctl_boot_up_conf ()
{
service_file="
[Unit]
Description=FRP Service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
ExecStart=/root/frp/frps -c /root/frp/frps.ini
Restart=always
RestartSec=1min
ExecStop=/usr/bin/killall frps

[Install]
WantedBy=multi-user.target
"
}

service_boot_up_conf ()
{
init_d='#!/bin/sh
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
exit'
}

Server_Setting ()
{
Server_Conf_file="[common]
bind_addr = ${Server_IP}
bind_port = 7000
kcp_bind_port = 7000
dashboard_port = 7500
dashboard_user = ${User}
dashboard_pwd = ${Password}
vhost_http_port = ${Vhost_http_port}
vhost_https_port = ${Vhost_https_port}
log_file = ./frps.log
log_level = info
log_max_days = 3
privilege_token = rpLjPOgPWDiaZKDe
max_pool_count = 50
tcp_mux = true
"
}

Client_Setting ()
{
Clent_Conf_file="[common]
server_addr = ${Server_IP}
server_port = 7000
log_file = ./frpc.log
log_level = info
log_max_days = 3
privilege_token = rpLjPOgPWDiaZKDe
admin_addr = 127.0.0.1
admin_port = 7400
admin_user = ${User}
admin_pwd = ${Password}
pool_count = 5
tcp_mux = true
login_fail_exit = true
protocol = tcp
"
}

Server_strutrue ()
{
some_setting
frp_version="0.16.1"
Structure="$(uname -p | grep -o 64)"
if [ ${Structure} -eq 64 ]; then
cpus="amd64"
else
cpus="arm"
fi
dw_url="https://github.com/fatedier/frp/releases/download/v${frp_version}/frp_${frp_version}_linux_${cpus}.tar.gz"
frp_package="frp_${frp_version}_linux_${cpus}.tar.gz"
frp_name="frp_${frp_version}_linux_${cpus}"
}

Install_frp ()
{
some_setting
Server_Setting
Client_Setting
Server_strutrue
cd ${Install_Path}
	echo "檢查使否已安裝frp..."
		if [ -d "/root/frp" ]; then
			echo "已安裝frp"
			echo "是否要重新安裝?"
			echo "(1).Yes (2).No"
			read -p "請輸入(1-2):" decide
				case ${decide} in
				1)
					cd ${Install_Path}
					killall frps || echo "frps have been stop"
					wait
					rm -rf frp
					rm -rf /etc/init.d/frps
					rm -rf /etc/systemd/system/frp.service
					wait
					echo "uninstall success"
					echo "reinstalling..."
					wget -P ${Install_Path} ${dw_url}
					wait
					tar -zxvf  ${frp_package}
					wait
					mv ${frp_package} frp
					wait
					rm -rf /root/${frp_package}
					wait
					if [ ${platform} -eq 1 ]; then
					echo "${Server_Conf_file}" > /root/frp/frps.ini
					wait
					elif [ ${platform} -eq 2 ]; then
					echo "${Clent_Conf_file}" > /root/frp/frpc.ini
					wait
					else
					continue
					fi
					wait
					echo "reinstall success"
					read -p "Press any key to continue." var
					;;
				2)
					continue
					;;
					esac
		else
				cd ${Install_Path}
				echo "安裝中..."
				wget -P ${Install_Path} ${dw_url}
				wait
				tar -zxvf  ${frp_package}
				wait
				mv ${frp_name} frp
				wait
				rm -rf ${frp_package}
				wait
					if [ ${platform} -eq 1 ]; then
					echo "${Server_Conf_file}" > /root/frp/frps.ini
					wait
					elif [ ${platform} -eq 2 ]; then
					echo "${Clent_Conf_file}" > /root/frp/frpc.ini
					wait
					else
					continue
					fi
		fi
}

Start_frp ()
{
frp_path="/root/frp"
cd ${frp_path}
	case ${platform} in
	1)
		if [ -d "/root/frp" ]; then
		nohup="/usr/bin/nohup"
		${nohup} /root/frp/frps -c /root/frp/frps.ini  > /root/frp/nohup-frps.out 2>&1&
		echo "starting frps server"
		else
		echo "frp have not been install"
		fi
		;;
	2)
		if [ -d "/root/frp" ]; then
		nohup="/usr/bin/nohup"
		${nohup} /root/frp/frpc -c /root/frp/frpc.ini  > /root/frp/nohup-frpc.out 2>&1&
		echo "starting frpc server"
		else
		echo "frp have not been install"
		fi
		;;	
	esac
}

Stop_frp () 
{
some_setting
	case ${platform} in
	1)
		if [ -f "/usr/bin/killall" ]; then
		echo ""
		else
		yum install psmisc -y || apt-get install psmisc -y || continue
		fi
		wait
		if [ "${frps_task}" = "frps" ]; then
		${kill_task_frps}
		wait
		echo "frp server stop success"
		read -p "Press any key to continue." var
		clear
		else
		echo "frps have not start"
		fi
		;;
	2)
		if [ -f "/usr/bin/killall" ]; then
		echo ""
		else
		wait
		yum install psmisc -y || apt-get install psmisc -y || continue
		fi
		if [ "${frpc_task}" = "frpc" ]; then
		${kill_task_frpc}
		wait
		echo "frp client stop success"
		read -p "Press any key to continue." var
		clear
		else
		echo "frpc have not been start"
		fi
		;;
	esac
}

frp_boot_up ()
{
some_setting
systemctl_boot_up_conf
service_boot_up_conf
	if [ "${search_dash}" = "dash" ]; then
		sudo dpkg-reconfigure dash
		wait
		read -p "Press any key to continue." var
	else
		if [  "${systemctl}" = "/bin/systemctl" ]; then
			if [ -d "/usr/lib/systemd/system" ]; then
			echo "${service_file}" > /usr/lib/systemd/system/frp.service
			chmod +x /usr/lib/systemd/system/frp.service
			else
			echo "/usr/lib/systemd/system/system folder does not exist"
			echo "Creating..."
			mkdir -p /usr/lib/systemd/system
			echo "${service_file}" > /usr/lib/systemd/system/frp.service
			chmod +x /usr/lib/systemd/system/frp.service
			fi
			wait
			systemctl enable frp.service
			echo "add success"
			echo "systemctl [start|stop|status|restart|enable|disable] frp.service"
			read -p "Press any key to continue." var
			
		else
			if [ -d "/root/frp" ]; then
			continue
			else
			mkdir -p /root/frp
			fi
			if [ -f "/etc/init.d/frp" ]; then
			continue
			else
			touch /etc/init.d/frp
			fi
			chmod 755 /etc/init.d/frp
			if [ -f "/root/frp/frp-start.sh" ]; then
			continue
			else
			touch /root/frp/frp-start.sh
			fi
			chmod +x /root/frp/frp-start.sh
			wait
			if [ ${platform} -eq 1]; then
			echo "nohup="/usr/bin/nohup" 
			$nohup /root/frp/frps -c /root/frp/frps.ini &" > /root/frp/frp-start.sh
			elif [ ${platform} -eq 2]; then
			echo "nohup="/usr/bin/nohup"
			$nohup /root/frp/frpc -c /root/frp/frpc.ini &" > /root/frp/frp-start.sh
			else
			echo "Oops!!! Something Error"
			break
			fi
			wait
			echo "${init_d}" > /etc/init.d/frp
			wait
			update-rc.d frp defaults
			wait
			echo "add success"
			echo "service frp (start|stop|restart)"
			read -p "Press any key to continue." var
			
		fi
	fi
}

Uninstall_frp ()
{
some_setting
Server_strutrue
		if [ "${frps_task}" = "frps" ]; then
		killall frps 
		echo "frp server have been stop"
		elif [ "${frpc_task}" = "frpc" ]; then
		killall frpc
		echo "frp client have been stop"
		wait
		else
		continue
		fi
		wait
		if [ -d "/root/frp" ]; then
		rm -r /root/frp
		else
		continue
		fi
		if [ -f "/root/${frp_package}" ]; then
		rm -r /root/${frp_package}
		else
		continue
		fi
		if [ -f "/etc/init.d/frp*" ]; then
		rm -r /etc/init.d/frps
		rm -r /etc/init.d/frpc
		else
		continue
		fi
		if [ -f "/usr/lib/systemd/system/frp.service" ]; then
		rm -r /usr/lib/systemd/system/frp.service
		else
		continue
		fi
		echo "uninstall success"
		wait
		read -p "Press any key to continue." var
}

echo ""
echo "choose whitch frp platform you want to use"
echo "(1).frp for server"
echo "(2).frp for client"
echo "(3).quit"
read -p "Please Input Number (1-3):" platform
until false
do
	case ${platform} in
1)
echo "(1).Install frps"
echo "(2).Start frps"
echo "(3).Stop frps"
echo "(4).Add frps to boot up"
echo "(5).Edit frps config"
echo "(6).Watch frps log"
echo "(7).Uninstall frps"
echo "(8).Exit"
read -p "Please Input Number (1-8):" choice
	case ${choice} in
	1)	
		Ask_answer
		Install_frp
	;;
	2)	Start_frp
	;;
	3)	Stop_frp
	;;
	4)	frp_boot_up
	;;
	5)	vim /root/frp/frps.ini
	;;
	6)
		cd /root/frp
		watch tail frp*.log nohup-frps.out
	;;
	7)	Uninstall_frp
	;;
	8)	break
	;;
	esac
;;
2)
echo "(1).Install frpc"
echo "(2).Start frpc"
echo "(3).Stop frpc"
echo "(4).Add frpc to boot up"
echo "(5).Edit frpc config"
echo "(6).Watch frpc log"
echo "(7).Uninstall frpc"
echo "(8).Exit"
read -p "Please Input Number (1-8):" choice
	case ${choice} in
	1)	
		Ask_answer
		Install_frp
	;;
	2)	
	some_setting
	cd ${Install_Path}/frp
	Start_frp
	;;
	3)	Stop_frp
	;;
	4)	frp_boot_up
	;;
	5)	vim /root/frp/frpc.ini
	;;
	6)	
		cd /root/frp
		watch tail frp*.log nohup-frpc.out
	;;
	7)	Uninstall_frp
	;;
	8)	break
	;;
	esac
;;
3)
exit
;;
*)
	echo "Error Input Please Try Again"
;;
esac
done
done