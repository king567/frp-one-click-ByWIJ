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

COLOR_REST='\e[0m'
COLOR_GREEN='\e[0;32m';
COLOR_RED='\e[0;31m';
COLOR_YELLOW='\033[1;93m'
some_setting ()
{
frp_path="/root/frp"
Install_Path="/root"
search_dash="$(ls -l /bin/sh | grep -o dash)"
systemctl="$(ls /bin/systemctl)"
}

Ask_answer ()
{
read -p "please input your server IP : " Server_IP
read -p "Please Input Frp Server Port : " Server_Port
read -p "add dashboard user : " User
read -p "input user password : " Password
read -p "input http Virtual host Port : " Vhost_http_port
read -p "input https Virtual host Port : " Vhost_https_port
Server_IP=${Server_IP:="0.0.0.0"}
Server_Port=${Server_Port:="7000"}
User=${User:="king"}
Password=${Password:="Happydaygo4"}
Vhost_http_port=${Vhost_http_port:="8080"}
Vhost_https_port=${Vhost_https_port:="9090"}
}

Ask_answer_client ()
{
read -p "Please Input Frp Server IP : " Server_IP
read -p "Please Input Frp Server Port : " Server_Port
read -p "Add dashboard user : " User
read -p "Input user password : " Password
Server_IP=${Server_IP:="0.0.0.0"}
Server_Port=${Server_Port:="7000"}
User=${User:="king"}
Password=${Password:="Happydaygo4"}
}
systemctl_boot_up_conf ()
{
if [ ${platform} -eq 1 ]; then
service_file="[Unit]
Description=FRP Server
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

elif [ ${platform} -eq 2 ]; then
service_file="[Unit]
Description=FRP Client
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
ExecStart=/root/frp/frpc -c /root/frp/frpc.ini
Restart=always
RestartSec=1min
ExecStop=/usr/bin/killall frpc

[Install]
WantedBy=multi-user.target
"
fi
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
bind_port = ${Server_Port}
kcp_bind_port = ${Server_Port}
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
server_port = ${Server_Port}
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
frp_version=$(wget --no-check-certificate -qO- https://api.github.com/repos/fatedier/frp/releases | grep -o '"tag_name": ".*"' |head -n 1| sed 's/"//g;s/v//g'| sed 's/tag_name: //g')
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
	echo "checking frp..."
		if [ -d "/root/frp" ]; then
			echo "You had been installed frp"
			echo "Do you want to reinstall it?"
			echo "(1).Yes (2).No"
			read -p "Please Input Number (1-2): " decide
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
					mv ${frp_name} frp
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
					echo -e "\n${COLOR_GREEN}reinstall success !!!${COLOR_REST}\n"
					;;
				2)
					continue
					;;
					esac
		else
				cd ${Install_Path}
				echo "Installing..."
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
					echo -e "\n${COLOR_RED}Oops Something Error !!!${COLOR_REST}\n"
					fi
				wait
				echo -e "\n${COLOR_GREEN} Install Success !!!${COLOR_REST}\n"
		fi
}

Start_frp ()
{
frp_path="/root/frp"
cd ${frp_path}
	case ${platform} in
	1)
		if [ -d "/root/frp" ]; then
		cd /root/frp
		(./frps -c ./frps.ini &) 
		wait
		echo -e "\n${COLOR_GREEN}starting frp server${COLOR_REST}\n"
		else
		echo -e "\n${COLOR_RED}frp have not been install${COLOR_REST}\n"
		fi
		;;
	2)
		if [ -d "/root/frp" ]; then
		cd /root/frp
		(./frpc -c ./frpc.ini &) 
		wait
		echo -e "\n${COLOR_GREEN}starting frp client${COLOR_REST}\n"
		else
		echo -e "\n${COLOR_RED}frp have not been install${COLOR_REST}\n"
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
		yum install psmisc -y || apt-get install psmisc -y || echo ""
		fi
		wait
		if [ "$(ps -e | grep -o frps)" = "frps" ]; then
		killall frps
		wait
		echo -e "\n${COLOR_GREEN}frp server stop success${COLOR_REST}\n"
		else
		echo -e "\n${COLOR_RED}frps have not start${COLOR_REST}\n"
		fi
		;;
	2)
		if [ -f "/usr/bin/killall" ]; then
		echo ""
		else
		wait
		yum install psmisc -y || apt-get install psmisc -y || echo ""
		fi
		if [ "$(ps -e | grep -o frpc)" = "frpc" ]; then
		killall frpc
		wait
		echo -e "\n${COLOR_GREEN}frp client stop success${COLOR_REST}\n"
		else
		echo -e "\n${COLOR_RED}frpc have not been start${COLOR_REST}\n"
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
			systemctl daemon-reload
			systemctl enable frp.service
			echo -e "\n${COLOR_GREEN}add success${COLOR_REST}\n"
			echo -e "\n${COLOR_GREEN}systemctl [start|stop|status|restart|enable|disable] frp.service${COLOR_REST}\n"
			
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
			if [ ${platform} -eq 1 ]; then
			echo "nohup="/usr/bin/nohup" 
			$nohup /root/frp/frps -c /root/frp/frps.ini &" > /root/frp/frp-start.sh
			elif [ ${platform} -eq 2 ]; then
			echo "nohup="/usr/bin/nohup"
			$nohup /root/frp/frpc -c /root/frp/frpc.ini &" > /root/frp/frp-start.sh
			else
			echo -e "\n${COLOR_RED}Oops!!! Something Error${COLOR_REST}\n"
			break
			fi
			wait
			echo "${init_d}" > /etc/init.d/frp
			wait
			update-rc.d frp defaults
			wait
			echo "add success"
			echo "\n${COLOR_GREEN}service frp (start|stop|restart)${COLOR_REST}\n"		
		fi
	fi
}

Uninstall_frp ()
{
Server_strutrue
		if [ "$(ps -e | grep -o frps)" = "frps" ]; then
		killall frps 
		echo "frp server have been stop"
		elif [ "$(ps -e | grep -o frpc)" = "frpc" ]; then
		killall frpc
		echo "frp client have been stop"
		else
		echo "frp service have not process"
		fi
		
		if [ -d "/root/frp" ]; then
		rm -rf /root/frp
		echo "rmove /root/frp folder success"
		else
		echo "/root/frp folder not exist" 
		fi
		if [ -f "/root/${frp_package}" ]; then
		rm -rf /root/${frp_package}
		echo "rmove /root/${frp_package} success" 
		else
		echo "/root/${frp_package} file not exist" 
		fi
		if [ -f "/etc/init.d/frp*" ]; then
		rm -rf /etc/init.d/frps
		rm -rf /etc/init.d/frpc
		echo "rmove /etc/init.d/frp success"
		else
		echo "/etc/init.d/frp not exist" 
		fi
		if [ -f "/usr/lib/systemd/system/frp.service" ]; then
		rm -rf /usr/lib/systemd/system/frp.service
		echo "rmove frp.service success" 
		else
		echo "frp.service not exist" 
		fi
		echo -e "\n${COLOR_GREEN}uninstall success${COLOR_REST}\n"
		wait
}

Watch_log ()
{
if [ -f "$(ls /root/frp/frp*.log)" ]; then
	cd /root/frp
	watch tail frp*.log 
else
	echo -e "\n${COLOR_RED}Log file does not exist!!${COLOR_REST}\n"
fi
}

Edit_frp_setting ()
{
if [ ${platform} -eq 1 ]; then
	if [ -f "/root/frp/frps.ini" ]; then
	vim /root/frp/frps.ini
	else
	echo -e "\n ${COLOR_RED}frps.ini file does not exist !!!${COLOR_REST}\n"
	fi
elif [ ${platform} -eq 2 ]; then
	if [ -f "/root/frp/frpc.ini" ]; then
	vim /root/frp/frpc.ini
	else
	echo -e "\n ${COLOR_RED}frpc.ini file does not exist !!!${COLOR_REST}\n"
	fi
else
	echo -e "\n ${COLOR_RED}Oops something Error !!!${COLOR_REST}\n"
fi
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
	5)	Edit_frp_setting
	;;
	6)  Watch_log
	;;
	7)	Uninstall_frp
	;;
	8)	break
	;;
	*)
	echo -e "\n${COLOR_RED}Error Input Please Try Again${COLOR_REST}\n"
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
	5)	Edit_frp_setting
	;;
	6)  Watch_log
	;;
	7)	Uninstall_frp
	;;
	8)	break
	;;
	*)
	echo -e "\n${COLOR_RED}Error Input Please Try Again${COLOR_REST}\n"
	;;
	esac
;;
3)
exit
;;
*)
	echo -e "\n${COLOR_RED}Error Input Please Try Again${COLOR_REST}"
	break
;;
esac
done
done