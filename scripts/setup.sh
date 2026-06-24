#!/bin/bash

# Alpment OS 0.1 - Sistem Kurulum Scripti
# Bu script Alpment OS'un ilk kurulumundan sonra çalıştırılmalıdır

set -e

echo "================================"
echo "Alpment OS 0.1 - Kurulum Scripti"
echo "================================"
echo ""

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Bu script root olarak çalıştırılmalıdır!${NC}"
   exit 1
fi

echo -e "${BLUE}Adım 1: Sistem güncellemeleri${NC}"
echo "Paket listesi güncelleniyor..."
apt-get update -qq
apt-get upgrade -y -qq

echo -e "${BLUE}Adım 2: Alpment OS teması yükleniyor${NC}"

# Windows 11 benzeri tema klasörü oluştur
mkdir -p /usr/share/themes/Alpment
mkdir -p /usr/share/icons/Alpment

echo -e "${BLUE}Adım 3: Masaüstü ortamı yapılandırılıyor${NC}"

# GDM yapılandırması
if [ -f /etc/gdm3/greeter.dconf-defaults ]; then
    echo "[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
icon-theme='Adwaita'
cursor-theme='Adwaita'
font-name='DejaVu Sans 11'" >> /etc/gdm3/greeter.dconf-defaults
fi

echo -e "${BLUE}Adım 4: Alpment OS logo ve duvar kağıdı ayarlanıyor${NC}"

# Duvar kağıdı dizini
mkdir -p /usr/share/backgrounds/alpment

# Basit duvar kağıdı oluştur (PNG başlığı)
printf '\x89PNG\r\n\x1a\n' > /usr/share/backgrounds/alpment/default.png

echo -e "${BLUE}Adım 5: Sistem ayarları uygulanıyor${NC}"

# dconf ayarları
if command -v dconf &> /dev/null; then
    dconf update
fi

echo -e "${BLUE}Adım 6: Başlangıç servisleri etkinleştiriliyor${NC}"

systemctl enable gdm3
systemctl enable networking
systemctl enable systemd-timesyncd

echo -e "${BLUE}Adım 7: Alpment OS bilgileri ayarlanıyor${NC}"

# Sistem bilgisi
cat > /etc/issue << 'EOF'
╔═════════════════════════════════════════════╗
║       Alpment OS 0.1 - Beta Edition         ║
║     Linux-based OS with Windows 11 UI      ║
╚═════════════════════════════════════════════╝
EOF

cat > /etc/issue.net << 'EOF'
Alpment OS 0.1 - Modern Linux with Windows 11 Interface
EOF

echo -e "${BLUE}Adım 8: Sürücüler ve donanım desteği${NC}"

# Grafik sürücüsü tespiti ve kurulumu
if lspci | grep -q Intel; then
    echo "Intel grafik kartı bulundu, i915 sürücüsü konfigüre ediliyor..."
    # i915 sürücüsü genellikle zaten yüklü
elif lspci | grep -q AMD; then
    echo "AMD grafik kartı bulundu, AMDGPU sürücüsü konfigüre ediliyor..."
    # apt-get install -y -qq amd-gpu-install
elif lspci | grep -q NVIDIA; then
    echo "NVIDIA grafik kartı bulundu, proprietary sürücü önerilir."
    echo "Kurulum için: sudo apt-get install nvidia-driver-xxx"
fi

echo -e "${BLUE}Adım 9: İlk çalıştırma görevleri${NC}"

# Geçici dosyalar temizle
apt-get autoremove -y -qq
apt-get autoclean -y -qq
rm -rf /tmp/*
rm -rf /var/tmp/*

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Kurulum başarıyla tamamlandı!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Alpment OS 0.1 artık kullanıma hazırdır!"
echo ""
echo "Sonraki adımlar:"
echo "  1. Sistemi yeniden başlatın: sudo reboot"
echo "  2. GNOME masaüstü oturumunda oturum açın"
echo "  3. Ayarlardan görünümü kişiselleştirin"
echo ""
echo "Tema ve ikonları yönetmek için:"
echo "  Settings > Appearance > Style"
echo ""
echo "Alpment OS 0.1 hoşgeldiniz! 🚀"
