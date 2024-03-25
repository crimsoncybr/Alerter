# Alerter
Alerter is Connection Monitoring and Service Management Script

Overview
This script is designed to monitor established network connections continuously and manage services on a Linux system. It logs incoming connections, scans their IP addresses using `geoiplookup` and `nmap`, and displays the current established connections on the system. Additionally, it provides options to start specific services or start all services at once.

Connection Monitoring
- Continuously monitor established network connections.
- Log IP addresses of incoming connections.
- Perform IP address scanning using `geoiplookup` and `nmap`.
- Display information about established connections, including local address, foreign address, and associated PID/program name.
- Log all activity in `scanned_ips_info.log`.

Prerequisites
- This script must be run with root privileges (`sudo`).
- The following packages are required:
    - `geoip-bin`
    - `nmap`

Installation
1. Clone or download the script to your Linux system.
2. Ensure that the script has executable permissions using `chmod +x script_name.sh`.
3. Run the script with `./script_name.sh`.

Usage
- Run the script with root privileges (`sudo ./script_name.sh`).
- Follow the on-screen instructions to:
    - Start specific services (SMB, SSH, FTP) or all services.
    - Monitor established connections.

Functionality
Service Management
- Start specific services:
    - SMB (Samba)
    - SSH (Secure Shell)
    - FTP (vsftpd)
- Start all services at once.


## Notes
- Ensure that `geoip-bin` and `nmap` packages are installed on your system before running the script. The script attempts to install `geoip-bin` automatically if it's not already installed.
- Running this script requires root privileges.
- The script must be run on a Linux system.
- It's recommended to review the script and understand its functionality before execution.


