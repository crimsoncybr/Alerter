#!/bin/bash

# Check if the user is root
if [ "$(whoami)" != "root" ]; then
    echo -e "\033[1;31m This script must be run as root.\e[0m"
    exit 1
else 
    echo -e "\033[1;32m You are running as root. Proceeding with the script.\e[0m"
fi

# Check if geoiplookup is installed and install if not
if ! dpkg -s geoip-bin &>/dev/null; then
    echo -e "\033[1;31m geoiplookup is not installed, starting installation\033[0m"
    sudo apt-get install -qqy geoip-bin
    echo -e "\033[1;32m geoiplookup has been installed.\e[0m"
fi

Ephoc_Time=$(date +%s)

# Function to check service status
function check_status() {
    local service_name=$1
    local service_display=$2

    # Enable and active status variable
    enabled_status=$(systemctl is-enabled "$service_name" 2>/dev/null)
    active_status=$(systemctl is-active "$service_name" 2>/dev/null)

    # If statement that checks if the service is active/enabled and colors the output in red/green
    if [[ "$enabled_status" == "enabled" ]]; then
        enabled_output="\033[1;32m$enabled_status\e[0m"  # Bold Green
    else
        enabled_output="\033[1;31m$enabled_status\e[0m"  # Bold Red
    fi

    if [[ "$active_status" == "active" ]]; then
        active_output="\033[1;32m$active_status\e[0m"  # Bold Green
    else
        active_output="\033[1;31m$active_status\e[0m"  # Bold Red
    fi

    echo -e "\033[1;35m The service $service_display is:\e[0m [$enabled_output]\n \033[1;35mThe service $service_display is :\e[0m [$active_output] "
}

# Function to continuously monitor connections, log IPs, scan them, and display connections
function MONITOR() {
    mkdir -p scan
    # Create an empty file to store scanned IPs
    touch scanned_ips.txt

    # Loop to continuously monitor connections
    while true; do
        # Capture netstat output, log IPs that try to connect, and exclude 0.0.0.0
        sudo netstat -tnap | awk '/ESTABLISHED/ {print $5}' | cut -d: -f1 | grep -v '0.0.0.0' | grep -vf scanned_ips.txt > IP.lst

        # Scan new IPs and log activity
        for IP in $(cat IP.lst | sort -u); do
            # Check if IP has been scanned before
            if ! grep -q "$IP" scanned_ips.txt; then
                echo -e "\033[1;34m Scanning $IP... \e[0m"
                sudo geoiplookup "$IP" | tee -a scan/${Ephoc_Time}_ips_info.log >/dev/null 2>&1
                sudo nmap -sV "$IP" | tee -a scan/${Ephoc_Time}_ips_info.log >/dev/null 2>&1
                echo "$IP" >> scanned_ips.txt
                echo -e "\033[1;33m $IP data was saved to scan/${Ephoc_Time}_ips_info.log \e[0m"
            fi
        done

        # Clear the screen
        clear

        # Show current connections on screen
        echo -e "\033[1;34m Current Established Connections: \e[0m"
        echo -e "\033[1;34m All data will be saved in scanned_ips_info.log \e[0m"

        # Header for the table
        printf "%-20s %-15s %-15s\n" "Local Address" "Foreign Address" "PID/Program name"

        # Display established connections
        sudo netstat -tnap | awk '$6 == "ESTABLISHED" {printf "%-20s %-15s %-15s\n", $4, $5, $7}'

        # Wait for a few seconds before repeating the loop
        sleep 1
    done
}

# A function of options for the user to choose which file to view.
function SERVICE() {
    # A selection menu for the user.
    echo -e "\033[1;34m Choose an option: \e[0m"
    echo -e "\033[1;34m 1. Start smb service \e[0m"
    echo -e "\033[1;34m 2. Start ssh service \e[0m"
    echo -e "\033[1;34m 3. Start ftp service \e[0m"
    echo -e "\033[1;34m 4. Start all services \e[0m"
    echo -e "\033[1;34m 5. Stop all services \e[0m"
    read -p "Enter the number of your choice, any other choice will exit the script: " CHT

    # A choice menu for the user 
    case $CHT in
        1)
            # Starts smb service.
            sudo systemctl enable smbd >/dev/null 2>&1
            sudo systemctl start smbd >/dev/null 2>&1
            check_status "smbd" "SMB"
            MONITOR
        ;;
        2)
            # Start ssh service.
            sudo systemctl enable ssh >/dev/null 2>&1
            sudo systemctl start ssh >/dev/null 2>&1
            check_status "ssh" "SSH"
            MONITOR
        ;;
        3)
            # Start ftp service.
            sudo systemctl enable vsftpd >/dev/null 2>&1
            sudo systemctl start vsftpd >/dev/null 2>&1
            check_status "vsftpd" "FTP"
            MONITOR
        ;;
        4)
            # Starts all services.
            sudo systemctl enable smbd >/dev/null 2>&1
            sudo systemctl start smbd >/dev/null 2>&1
            check_status "smbd" "SMB"

            sudo systemctl enable ssh >/dev/null 2>&1
            sudo systemctl start ssh >/dev/null 2>&1
            check_status "ssh" "SSH"

            sudo systemctl enable vsftpd >/dev/null 2>&1
            sudo systemctl start vsftpd >/dev/null 2>&1
            check_status "vsftpd" "FTP"

            MONITOR
        ;;
        5)
            # Stops all services.
            sudo systemctl stop smbd >/dev/null 2>&1
            sudo systemctl disable smbd >/dev/null 2>&1
            check_status "smbd" "SMB"

            sudo systemctl stop ssh >/dev/null 2>&1
            sudo systemctl disable ssh >/dev/null 2>&1
            check_status "ssh" "SSH"

            sudo systemctl stop vsftpd >/dev/null 2>&1
            sudo systemctl disable vsftpd >/dev/null 2>&1
            check_status "vsftpd" "FTP"
        ;;
        *)
            # For any other input, the script will exit.
            echo -e "\033[1;34m Exiting script \e[0m"
            exit 1
        ;;
    esac
}

# Start selected services
SERVICE
