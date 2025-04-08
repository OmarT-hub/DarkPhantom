#!/bin/bash
# Check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root!"
    echo "🔰 Try: sudo $0"
    exit 1
fi
echo "                     ==================================="
echo "                     Welcome to DarkPhantom bash script!"
echo "                     ==================================="
echo
echo
echo "(1) Run Scan_Networks_To_csv"
echo "(2) Run Catch_Handshake_File"

read -p "Enter your choice: " choice

if [ "$choice" == "1" ]; then
    echo "Running scan_networks_to_csv"
    bash .NETWORKS.sh
elif [ "$choice" == "2" ]; then
    echo "Running Catch_Handshake_File"
   sudo bash .catch_HS.sh
else
    echo "Invalid choice. Please run the script again and choose 1 or 2."
fi
