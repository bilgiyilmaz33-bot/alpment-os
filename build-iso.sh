#!/bin/bash

# Alpment OS 0.1 - ISO Builder Script
# Bu script Alpment OS'un ISO dosyasını oluşturur

set -e

echo "================================"
echo "Alpment OS 0.1 - ISO Builder"
echo "================================"

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Kontrol: Root kullanıcısı mı?
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Bu script root olarak çalıştırılmalıdır!${NC}"
   echo "Şu şekilde çalıştırın: sudo ./build-iso.sh"
   exit 1
fi

# Kontrol: Gerekli araçlar var mı?
echo -e "${YELLOW}Gerekli araçlar kontrol ediliyor...${NC}"

for tool in debootstrap mksquashfs xorriso grub-mkimage; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}$tool bulunamadı! Yükleyin:${NC}"
        echo "sudo apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin"
        exit 1
    fi
done

echo -e "${GREEN}Tüm araçlar bulundu!${NC}"

# Dizin yapısı
BUILD_DIR="alpment-build"
WORK_DIR="$(pwd)/$BUILD_DIR"
CHROOT_DIR="$WORK_DIR/chroot"
ISO_DIR="$WORK_DIR/iso"
OUT_DIR="$(pwd)/dist"

echo -e "${YELLOW}Çalışma dizinleri oluşturuluyor...${NC}"

rm -rf $BUILD_DIR
mkdir -p $CHROOT_DIR $ISO_DIR/boot/grub $ISO_DIR/boot/isolinux $OUT_DIR

# Ubuntu/Debian tabanlı sistem oluştur (minimal)
echo -e "${YELLOW}Temel sistem yükleniyor (debootstrap)...${NC}"
echo "Bu birkaç dakika alabilir..."

debootstrap --include=linux-image-generic,grub-pc,systemd,apt,wget,curl --arch amd64 jammy $CHROOT_DIR http://archive.ubuntu.com/ubuntu/

echo -e "${GREEN}Temel sistem yüklendi!${NC}"

# Chroot ortamında özelleştirmeler
echo -e "${YELLOW}Sistem özelleştiriliyor...${NC}"

cat > $CHROOT_DIR/setup-alpment.sh << 'EOF'
#!/bin/bash

# Alpment OS özel kurulumu

# Paket kaynaklarını güncelle
apt-get update

# GNOME masaüstü ortamını kur (Windows 11 benzeri tema için)
apt-get install -y --no-install-recommends \
    gnome-shell \
    gnome-control-center \
    gnome-terminal \
    nautilus \
    gdm3 \
    fonts-dejavu \
    fonts-liberation \
    pulseaudio \
    alsa-utils \
    network-manager \
    wireless-tools \
    wpasupplicant

# Ek araçlar
apt-get install -y --no-install-recommends \
    vim \
    nano \
    git \
    curl \
    wget \
    htop \
    neofetch \
    sudo

# Alpment OS temayı kur
mkdir -p /usr/share/themes/Alpment

# GDM ve GNOME için yapılandırma
echo "[org/gnome/desktop/interface]
" > /etc/dconf/db/site.d/01-alpment

# Bootloader yapılandırması
echo "GRUB_CMDLINE_LINUX=\"quiet splash vt_handoff\"
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR=\"Alpment OS\"" >> /etc/default/grub

echo "Alpment OS 0.1" > /etc/issue
echo "Welcome to Alpment OS 0.1 - Modern Linux with Windows 11 Interface" >> /etc/issue

# Systemd servisleri etkinleştir
systemctl enable gdm3
systemctl enable networking

echo "Alpment OS kurulumu tamamlandı!"
EOF

chmod +x $CHROOT_DIR/setup-alpment.sh

echo -e "${YELLOW}Chroot içinde kurulum yapılıyor...${NC}"
chroot $CHROOT_DIR /setup-alpment.sh

echo -e "${GREEN}Sistem özelleştirmeleri tamamlandı!${NC}"

# Squashfs dosya sistemi oluştur
echo -e "${YELLOW}Dosya sistemi sıkıştırılıyor...${NC}"
mksquashfs $CHROOT_DIR $ISO_DIR/casper/filesystem.squashfs -e proc -e sys -e dev -e tmp -e run

echo -e "${GREEN}Dosya sistemi hazır!${NC}"

# GRUB yapılandırması
echo -e "${YELLOW}GRUB yapılandırması oluşturuluyor...${NC}"

cat > $ISO_DIR/boot/grub/grub.cfg << 'GRUB'
set default="0"
set timeout=3

menuentry "Alpment OS 0.1 (Live)" {
    linux   /boot/vmlinuz boot=casper quiet splash
    initrd  /boot/initrd.img
}

menuentry "Alpment OS 0.1 (Safe Mode)" {
    linux   /boot/vmlinuz boot=casper nomodeset quiet splash
    initrd  /boot/initrd.img
}
GRUB

# ISO dosyası oluştur
echo -e "${YELLOW}ISO dosyası oluşturuluyor...${NC}"
echo "Bu işlem biraz zaman alabilir..."

xorriso -as mkisofs \
    -iso-level 3 \
    -o $OUT_DIR/alpment-os-0.1.iso \
    -full-iso9660-filenames \
    -volid "Alpment OS 0.1" \
    -eltorito-boot boot/isolinux/isolinux.bin \
    -eltorito-catalog boot/isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot \
    -e EFI/alpment.efi \
    -no-emul-boot \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -isohybrid-aes-128 \
    $ISO_DIR

echo -e "${GREEN}ISO dosyası başarıyla oluşturuldu!${NC}"

# Temizle
echo -e "${YELLOW}Geçici dosyalar siliniyor...${NC}"
rm -rf $BUILD_DIR

echo ""
echo "================================"
echo -e "${GREEN}İŞLEM TAMAMLANDI!${NC}"
echo "================================"
echo ""
echo -e "${GREEN}ISO Dosyası:${NC} $OUT_DIR/alpment-os-0.1.iso"
echo -e "${GREEN}Dosya Boyutu:${NC} $(du -h $OUT_DIR/alpment-os-0.1.iso | cut -f1)"
echo ""
echo "USB'ye yazmak için:"
echo "  sudo dd if=$OUT_DIR/alpment-os-0.1.iso of=/dev/sdX bs=4M status=progress"
echo "  sudo sync"
echo ""
echo "Sanal makinede test etmek için:"
echo "  qemu-system-x86_64 -cdrom $OUT_DIR/alpment-os-0.1.iso -m 2048"
echo ""
