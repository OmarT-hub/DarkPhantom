#!/bin/bash

#set -x
FolderName=$(date +"%a_%d-%m-%Y")
FileName=$(date +"%H:%M:%S")

sudo -v || { echo "Error: Wrong sudo password!"; exit 1; }

# تعريف الألوان
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # إعادة اللون إلى الافتراضي


SEPARATOR="${CYAN}──────────────────────────────────────────${NC}"

echo
echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Change Directory to Other${NC}"
echo -e "$SEPARATOR"
echo
mkdir -p /mnt/hdd/networks  && cd /mnt/hdd/networks
pwd
echo
echo -e "$SEPARATOR"
# عرض الأجهزة المتصلة عبر USB
echo -e "${YELLOW}[INFO] Checking USB Devices...${NC}"
echo -e "$SEPARATOR"
echo
lsusb
sleep 2
echo
echo -e "$SEPARATOR"
# عرض معلومات الشبكة اللاسلكية
echo -e "${YELLOW}[INFO] Checking Wireless Configuration...${NC}"
echo -e "$SEPARATOR"
echo
iwconfig
sleep 2

echo
# تفعيل وضع المراقبة على كرت الشبكة
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Enabling Monitor Mode on wlan0...${NC}"
echo -e "$SEPARATOR"
echo
sudo airmon-ng start wlan0
sleep 2

echo
# قتل العمليات التي قد تؤثر على تشغيل الكرت
echo -e "$SEPARATOR"
echo -e "${RED}[INFO] Killing Conflicting Processes...${NC}"
echo -e "$SEPARATOR"
echo
sudo airmon-ng check kill
sleep 2



echo
# عرض معلومات الشبكة اللاسلكية مرة أخرى
echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Verifying Wireless Configuration...${NC}"
echo -e "$SEPARATOR"
echo
iwconfig
sleep 1
echo
echo -e "$SEPARATOR"
echo
lsusb
sleep 1


echo
# إزالة جهاز USB معين
echo -e "$SEPARATOR"
echo -e "${RED}[INFO] Removing USB Device...${NC}"
echo -e "$SEPARATOR"
echo
sudo bash -c "echo '1' > /sys/bus/usb/devices/1-1/remove"
sleep 2
lsusb
sleep 1



echo
# إلغاء تحميل برنامج تشغيل وحدة تحكم الـ PCI
echo -e "$SEPARATOR"
echo -e "${RED}[INFO] Unbinding PCI Device...${NC}"
echo -e "$SEPARATOR"
echo


echo -n "0000:00:0b.0" | sudo tee /sys/bus/pci/drivers/ehci-pci/unbind
echo
sleep 2
lsusb
sleep 1



echo
# إعادة تحميل برنامج تشغيل وحدة تحكم الـ PCI
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Binding PCI Device...${NC}"
echo -e "$SEPARATOR"
echo



echo -n "0000:00:0b.0" | sudo tee /sys/bus/pci/drivers/ehci-pci/bind
echo
echo -e "$SEPARATOR"
echo
sleep 2
lsusb
sleep 1

echo
# تشغيل airodump-ng لمدة 10 ثوانٍ فقط ثم الإيقاف تلقائيًا
echo -e "$SEPARATOR"
echo -e "${BLUE}[INFO] Running Airodump-ng for 1m seconds...${NC}"
echo -e "$SEPARATOR"
echo
mkdir -p $FolderName && cd $FolderName
sudo timeout 1m airodump-ng wlan0 -w $FileName  --output-format csv
sleep 2

# إيقاف وضع المراقبة وإعادة كرت الشبكة للوضع العادي
echo
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Stopping Monitor Mode...${NC}"
echo -e "$SEPARATOR"
echo
sudo airmon-ng stop wlan0
sleep 1
iwconfig
sleep 1
echo
# إعادة تشغيل خدمات الشبكة
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Restarting Network Services...${NC}"
echo -e "$SEPARATOR"
echo
sudo systemctl start wpa_supplicant && echo "Done" 
sleep 1
sudo systemctl start NetworkManager && echo "Done"
sleep 1


echo
echo -e "$SEPARATOR"
echo -e "${GREEN}[INFO] Process Completed Successfully!${NC}"
echo -e "$SEPARATOR"
echo
ping -c 4 google.com

echo
echo -e "$SEPARATOR"
echo -e "${RED}[INFO] The List File ($FileName-01.csv) in (/mnt/hdd/networks/$FolderName)<--Go to it!${NC}"
echo -e "$SEPARATOR"

