#!/bin/bash

	
		

		#Check if the user is root
		if [ "$(whoami)" != "root" ]; then
			echo -e "\033[1;32m This script must be run as root.\e[0m"
			exit 
		else 
			echo -e "\033[1;32m You are running as root. Proceeding with the script.\e[0m"
		fi
		
		
		#Check if geoiplookup is installed and install if not
		if ! dpkg -s geoip-bin &>/dev/null ; then
			echo -e "\033[1;31m geoiplookup is not installed, starting installation\033[0m"
			sudo apt-get install -qqy geoip-bin
			echo -e "\033[1;32m geoiplookup has been installed\e[0m."
		else
			>/dev/null 2>&1
		fi
	
	
		function SERVICE() {
    #A selection menu for the user.
    echo -e "\033[1;34m Choose an option: \e[0m"
    echo -e "\033[1;34m 1. Start smb service \e[0m"
    echo -e "\033[1;34m 2. Start ssh service \e[0m"
    echo -e "\033[1;34m 3. Start ftp service \e[0m"
    echo -e "\033[1;34m 4. Start all services \e[0m"
    read -p "Enter the number of your choice, any other choice will exit the script: " CHT

    case $CHT in
    1)
        #Starts smb service.
        echo -e "\033[1;32m Starting smb service \e[0m"
        sudo systemctl enable smb >/dev/null 2>&1
        sudo systemctl start smb >/dev/null 2>&1
        ;;
    2)
        #Starts ssh service.
        echo -e "\033[1;32m  Starting ssh service \e[0m"
        sudo systemctl enable ssh >/dev/null 2>&1
        sudo systemctl start ssh >/dev/null 2>&1
        ;;
    3)
        #Starts ftp service.
        echo -e "\033[1;32m Starting ftp service \e[0m"
        sudo systemctl enable vsftpd >/dev/null 2>&1
        sudo systemctl start vsftpd >/dev/null 2>&1
        ;;
    4)
        echo -e "\033[1;32m Starting all services \e[0m"
        sudo systemctl enable smb ssh vsftpd >/dev/null 2>&1
        sudo systemctl start smb ssh vsftpd >/dev/null 2>&1
        ;;
    *)
        #For any other input the script will exit.
        echo -e "\033[1;34m Exiting script \e[0m"
        exit 1
        ;;
    esac

}

		#Function to continuously monitor connections, log IPs, scan them, and display connections
		function MONITOR() {
			#Create an empty file to store scanned IPs
			touch scanned_ips.txt
    
		#Loop to continuously monitor connections
		while true; do
				#Capture netstat output, log IPs that try to connect, and exclude 0.0.0.0
				sudo netstat -tnap | awk '/ESTABLISHED/ {print $5}' | cut -d: -f1 | grep -v '0.0.0.0' | grep -vf scanned_ips.txt >> IP.lst
        
				#scan new IPs and log activity
				for IP in $(cat IP.lst | sort | uniq); do
					#Check if IP has been scanned before
					if ! grep -q "$IP" scanned_ips.txt; then
						echo -e "\033[1;34m Scanning $IP... \e[0m"
						sudo geoiplookup "$IP" | tee -a scanned_ips_info.log >/dev/null 2>&1
						sudo nmap -sV "$IP" | tee -a scanned_ips_info.log >/dev/null 2>&1
						echo "$IP" >> scanned_ips.txt
						echo -e "\033[1;33m $IP data was saved to info.txt \e[0m"
					fi
					done
				#Clear the screen
				clear
				
				# Show current connections on screen
				echo -e "\033[1;34m Current Established Connections: \e[0m"
				echo -e "\033[1;34m all data will be saved in scanned_ips_info.log \e[0m"
				
				# Header for the table
				printf "%-20s %-15s %-15s\n" "Local Address" "Foreign Address" "PID/Program name"
				
				# Display established connections
				sudo netstat -tnap | awk '$6 == "ESTABLISHED" {printf "%-20s %-15s %-15s\n", $4, $5, $7}'
				
				#Wait for a few seconds before repeating the loop
				sleep 1
				done
		

}
		
		#Start selected services
		SERVICE

		#Call function to monitor connections
		MONITOR
