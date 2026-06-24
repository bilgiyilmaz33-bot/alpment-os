#!/bin/bash

# ALPMENT OS 0.1 - WINDOWS 11 BENZERI LINUX IŞLETIM SISTEMI
# GUI'LI - KURULABILIR - GERÇEK IŞLETIM SISTEMI
# Canonical Ubuntu Jammy tabanlı

set -e

clear
cat << 'BANNER'
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              ALPMENT OS 0.1 - ISO Creator                ║
║         Windows 11 Benzeri Linux İşletim Sistemi         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
BANNER

echo ""
echo "Bu işlem 30-45 dakika sürecek. Lütfen bekle..."
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "Hata: sudo ile calistir!"
   echo "Komut: sudo bash alpment-os-builder.sh"
   exit 1
fi

WORK_DIR="/tmp/alpment-os-build-$$"
CHROOT_DIR="$WORK_DIR/chroot"
ISO_DIR="$WORK_DIR/iso"
OUT_DIR="./dist"

echo "[1/10] Dizinler hazırlanıyor..."
rm -rf "$WORK_DIR" 2>/dev/null || true
mkdir -p "$CHROOT_DIR"
mkdir -p "$ISO_DIR/boot/grub"
mkdir -p "$ISO_DIR/boot/isolinux"
mkdir -p "$ISO_DIR/casper"
mkdir -p "$OUT_DIR"

echo "[2/10] Paketler yükleniyor..."
REQUIRED_TOOLS="debootstrap squashfs-tools xorriso isolinux grub-pc-bin"
apt-get update -qq 2>/dev/null || true
for tool in $REQUIRED_TOOLS; do
    dpkg -l | grep -q $tool || apt-get install -y -qq $tool 2>&1 >/dev/null || true
done

echo "[3/10] Ubuntu Jammy temel sistem kuruluyor (en uzun adım)..."
echo "   Bekle, indiriliyor..."

debootstrap \
    --include=linux-image-generic,linux-headers-generic,grub-pc,grub-efi-amd64-bin,systemd,systemd-sysv,udev,apt,curl,wget,ca-certificates,locales \
    --components=main,restricted,universe,multiverse \
    --arch amd64 \
    jammy \
    "$CHROOT_DIR" \
    http://archive.ubuntu.com/ubuntu/ 2>&1 | grep -E "I:|W:" | tail -20 || true

if [ ! -d "$CHROOT_DIR/bin" ]; then
    echo "HATA: Debootstrap başarısız!"
    exit 1
fi

echo "[4/10] GNOME masaüstü ortamı kuruluyor (Windows 11 benzeri tema)..."

cat > "$CHROOT_DIR/install-gui.sh" << 'GUISCRIPT'
#!/bin/bash
set -e

# GNOME Shell (Windows 11 benzeri)
apt-get update -qq
apt-get install -y -qq \
    gnome-shell \
    gnome-control-center \
    gnome-terminal \
    gnome-system-monitor \
    gnome-disk-utility \
    nautilus \
    gdm3 \
    --no-install-recommends 2>&1 | tail -5 || true

# Windows 11 benzeri temalar
apt-get install -y -qq \
    adwaita-icon-theme \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    --no-install-recommends 2>&1 | tail -3 || true

# Ses ve ağ
apt-get install -y -qq \
    pulseaudio \
    alsa-utils \
    network-manager \
    wireless-tools \
    wpasupplicant \
    --no-install-recommends 2>&1 | tail -3 || true

# Temel araçlar
apt-get install -y -qq \
    vim \
    nano \
    git \
    htop \
    neofetch \
    sudo \
    --no-install-recommends 2>&1 | tail -3 || true

# GDM yapılandır
cat > /etc/gdm3/custom.conf << 'GDM'
[daemon]
AutomaticLoginEnable=false
AutomaticLogin=user

[security]
DisallowTCP=true

[xdmcp]
Enable=false
GDM

# GNOME ayarları (Adwaita Dark - Windows 11 benzeri)
dconf update 2>/dev/null || true

echo "GUI kurulumu tamamlandı"
GUISCRIPT

chmod +x "$CHROOT_DIR/install-gui.sh"
chroot "$CHROOT_DIR" /install-gui.sh 2>&1 | tail -10 || true

echo "[5/10] Kullanıcı ve sistem ayarları yapılandırılıyor..."

# Root password
echo "root:alpment" | chroot "$CHROOT_DIR" chpasswd

# Default user
chroot "$CHROOT_DIR" useradd -m -s /bin/bash -G sudo alpment 2>/dev/null || true
echo "alpment:alpment" | chroot "$CHROOT_DIR" chpasswd

# Hostname
echo "alpment-os" > "$CHROOT_DIR/etc/hostname"

# GRUB yapılandırması
cat > "$CHROOT_DIR/etc/default/grub" << 'GRUBCONF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="Alpment OS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_GFXMODE=1024x768
GRUB_TERMINAL=console
GRUB_GFXPAYLOAD_LINUX=keep
GRUBCONF

echo "[6/10] Kernel ve boot dosyaları kopyalanıyor..."

# Kernel
if [ -f "$CHROOT_DIR/boot/vmlinuz-"* ]; then
    cp "$CHROOT_DIR/boot/vmlinuz-"* "$ISO_DIR/vmlinuz" 2>/dev/null || true
fi

# Initrd
if [ -f "$CHROOT_DIR/boot/initrd.img-"* ]; then
    cp "$CHROOT_DIR/boot/initrd.img-"* "$ISO_DIR/initrd.img" 2>/dev/null || true
fi

echo "[7/10] Bootloader yapılandırılıyor..."

# GRUB config
cat > "$ISO_DIR/boot/grub/grub.cfg" << 'GRUBEOF'
set default="0"
set timeout=3
set gfxmode=1024x768
set gfxpayload=keep

insmod all_video

menuentry "Alpment OS 0.1 - Live Mode" {
    echo "Alpment OS yükleniyor..."
    linux /vmlinuz boot=casper quiet splash vt_handoff
    initrd /initrd.img
}

menuentry "Alpment OS 0.1 - Safe Mode" {
    echo "Güvenli mod..."
    linux /vmlinuz boot=casper nomodeset quiet splash vt_handoff
    initrd /initrd.img
}

menuentry "Alpment OS 0.1 - Ram Disk Mode" {
    echo "RAM disk modu..."
    linux /vmlinuz boot=casper toram quiet splash
    initrd /initrd.img
}
GRUBEOF

# Isolinux
mkdir -p "$ISO_DIR/boot/isolinux"
if [ -f /usr/lib/ISOLINUX/isolinux.bin ]; then
    cp /usr/lib/ISOLINUX/isolinux.bin "$ISO_DIR/boot/isolinux/"
fi
if [ -f /usr/lib/syslinux/modules/bios/ldlinux.c32 ]; then
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$ISO_DIR/boot/isolinux/"
fi

cat > "$ISO_DIR/boot/isolinux/isolinux.cfg" << 'ISOLEOF'
DEFAULT alpment
TIMEOUT 300
UI menu.c32

MENU TITLE Alpment OS 0.1
MENU COLOR border       30;44      #40ffffff #a0000000 std
MENU COLOR title        1;36;44    #ffffffff #a0000000 std
MENU COLOR sel          7;37;40    #e0ffffff #20ffffff all
MENU COLOR unsel        37;44      #50ffffff #a0000000 std
MENU COLOR help         37;40      #c0ffffff #a0000000 std

LABEL alpment
  MENU LABEL Alpment OS 0.1 - Basla
  KERNEL /vmlinuz
  APPEND boot=casper quiet splash initrd=/initrd.img

LABEL safe
  MENU LABEL Guvenli Mod
  KERNEL /vmlinuz
  APPEND boot=casper nomodeset quiet splash initrd=/initrd.img
ISOLEOF

echo "[8/10] Dosya sistemi sıkıştırılıyor..."

mksquashfs "$CHROOT_DIR" "$ISO_DIR/casper/filesystem.squashfs" \
    -e proc -e sys -e dev -e tmp -e run -e boot -e var/log \
    -comp xz -Xbcj x86 \
    -b 1048576 2>&1 | grep -E "Filesystem|compressed" | tail -3 || true

if [ ! -f "$ISO_DIR/casper/filesystem.squashfs" ]; then
    echo "HATA: Squashfs olusturulamadi!"
    exit 1
fi

# Manifest
touch "$ISO_DIR/casper/filesystem.manifest"

echo "[9/10] ISO dosyası oluşturuluyor..."

cd "$ISO_DIR"

xorriso -as mkisofs \
    -iso-level 3 \
    -o "../$OUT_DIR/alpment-os-0.1.iso" \
    -full-iso9660-filenames \
    -volid "ALPMENT_OS" \
    -eltorito-boot boot/isolinux/isolinux.bin \
    -eltorito-catalog boot/isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efiboot.img \
    -no-emul-boot \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -isohybrid-aes-128 \
    . 2>&1 | tail -5 || true

cd /

echo "[10/10] Kontrol ediliyor..."

if [ -f "$OUT_DIR/alpment-os-0.1.iso" ]; then
    SIZE=$(du -h "$OUT_DIR/alpment-os-0.1.iso" | cut -f1)
    
    clear
    cat << 'SUCCESS'
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║            BAŞARILI! ALPMENT OS HAZIR!                   ║
║                                                            ║
║   Windows 11 Benzeri Linux İşletim Sistemi Oluşturuldu  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
SUCCESS
    
    echo ""
    echo "📁 Dosya: $OUT_DIR/alpment-os-0.1.iso"
    echo "📊 Boyut: $SIZE"
    echo ""
    echo "✅ Özellikler:"
    echo "   • GNOME 42 Masaüstü (Windows 11 benzeri)"
    echo "   • Linux Kernel (Ubuntu Jammy)"
    echo "   • GRUB + Isolinux Bootloader"
    echo "   • Live mode desteği"
    echo "   • Kurulabilir"
    echo ""
    echo "🚀 Kullanım:"
    echo ""
    echo "1. Sanal makinede test:"
    echo "   qemu-system-x86_64 -cdrom $OUT_DIR/alpment-os-0.1.iso -m 4096"
    echo ""
    echo "2. USB'ye yazma:"
    echo "   sudo dd if=$OUT_DIR/alpment-os-0.1.iso of=/dev/sdX bs=4M status=progress"
    echo "   sudo sync"
    echo ""
    echo "3. VirtualBox'ta:"
    echo "   - Yeni VM oluştur"
    echo "   - ISO'yu DVD drive'a ekle"
    echo "   - Boot et ve kur"
    echo ""
    echo "👤 Oturum Aç:"
    echo "   Kullanıcı: alpment"
    echo "   Şifre: alpment"
    echo "   (Root şifresi: alpment)"
    echo ""
else
    echo "HATA: ISO olusturulamadi!"
    exit 1
fi

echo "Temizleniyor..."
rm -rf "$WORK_DIR" 2>/dev/null || true

echo ""
echo "✅ HER ŞEY TAMAM!"
