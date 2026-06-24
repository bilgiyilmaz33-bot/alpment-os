# Alpment OS 0.1
**Linux-based Operating System with Windows 11 Interface**

Alpment OS, modern bir Linux çekirdeği üzerinde Windows 11 benzeri kullanıcı arayüzü sunan özel bir işletim sistemidir.

## 🎯 Özellikler

- **Linux Çekirdeği**: Özürü modern Linux kernel
- **Windows 11 Arayüzü**: GNOME/KDE temelinde Windows 11 benzeri tasarım
- **Hafif ve Hızlı**: Minimum kaynak kullanımı
- **Özelleştirilmiş**: Alpment OS'a özel temalar ve araçlar
- **Açık Kaynak**: Tam olarak özürü ve değiştirilebilir

## 📋 Sistem Gereksinimleri

- **İşlemci**: 1 GHz veya daha hızlı
- **RAM**: Minimum 512 MB (önerilen 2 GB)
- **Disk**: 5 GB boş alan
- **Parti**: UEFI veya BIOS uyumlu

## 🚀 Hızlı Kurulum

### Adım 1: ISO Dosyası Oluştur
```bash
chmod +x build-iso.sh
./build-iso.sh
```

### Adım 2: USB'ye Yazma (Linux)
```bash
sudo dd if=alpment-os-0.1.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

### Adım 3: Önyükle ve Kur
1. USB'den başlat
2. Kurulum sihirbazını takip et
3. Windows 11 benzeri arayüzü keyfini çıkar!

## 📁 Proje Yapısı

```
alpment-os/
├── build-iso.sh              # ISO oluşturma scripti
├── kernel/
│   └── kernel.config         # Kernel yapılandırması
├── packages/
│   ├── packages.list         # Temel paketler
│   └── packages-desktop.list # Masaüstü paketleri
├── boot/
│   └── grub.cfg             # GRUB yapılandırması
├── themes/
│   ├── windows11-theme/     # Windows 11 tema dosyaları
│   └── icons/               # İkon seti
├── scripts/
│   ├── setup.sh             # Sistem kurulumu
│   └── customize.sh         # Özelleştirmeler
├── iso/
│   └── isolinux.cfg         # ISO önyükleme ayarları
└── README.md                # Bu dosya
```

## 🎨 Windows 11 Benzeri Tema

Alpment OS şu bileşenlerle Windows 11 benzeri görünüm sağlar:

- **Masaüstü Ortamı**: GNOME 42+ / KDE Plasma 5.25+
- **Tema**: Modern koyu/açık tema seçenekleri
- **İkonlar**: Windows 11 inspirasyonlu yuvarlak ikonlar
- **Duvar Kağıdı**: Minimalist ve modern tasarımlar
- **Başlat Menüsü**: Windows 11 benzeri merkezi başlat menüsü
- **Görev Çubuğu**: Alt tarafta başlat, sistem tepsisi ve pencereleri göster

## 🔧 Özelleştirme

### Kernel Parametrelerini Değiştir
```bash
cd kernel/
nano kernel.config
```

### Paketleri Özelleştir
```bash
nano packages/packages-desktop.list
```

### Temayı Düzenle
```bash
cd themes/windows11-theme/
nano gtk.css
```

## 📝 Lisans

Alpment OS GPL v3 lisansı altında yayınlanmıştır.

## 👨‍💻 Geliştirici

- **Alpment OS Team**
- Başlatılış: 2026
- Sürüm: 0.1 (Beta)

## 🤝 Katkı

Katkılarına açığız! Lütfen pull request gönder veya issue aç.

## ⚠️ Uyarı

Bu işletim sistemi geliştirilme aşamasındadır. Üretim ortamında kullanmadan önce sanal makinede test edin.

---

**Alpment OS 0.1** - Modern Linux, Windows 11 Tasarımı 🚀