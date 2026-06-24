# Alpment OS'a Katkı Sağlama

Alpment OS projesine katkı sağlamak için buradaki yönergeleri lütfen takip edin.

## Kod Yazım Kuralları

### Bash Scriptleri
- 4 boşluk girintileme kullan
- Açıklayıcı yorum satırları ekle
- `set -e` ile hata yönetimini sağla
- Renkli çıktı kullan (değişkenler: RED, GREEN, YELLOW, BLUE, NC)

### Yapılandırma Dosyaları
- Açıklayıcı yorumlar ekle
- Tutarlı biçimlendirme kullan
- Windows 11 benzeri uyumluluğu göz önünde bulundur

## Pull Request Süreci

1. **Fork** - Depoyu fork et
2. **Branch Oluştur** - Yeni bir branch oluştur: `git checkout -b feature/ozellik-adi`
3. **Değişiklikler Yap** - Kodunuzu yazın
4. **Commit Et** - Açıklayıcı mesajla commit et
5. **Push Et** - Branch'i push et
6. **Pull Request Aç** - Pull request açarak açıklamanızı yapın

## Issue Bildirme

Bir hata veya sorun bulduysanız, lütfen bir issue açın:

1. **Başlık**: Sorunu açık bir şekilde açıkla
2. **Açıklama**: Detaylı adımlar ve hata mesajları ekle
3. **Sistem Bilgileri**: İşletim sistemi, donanım, versiyon vb.
4. **Ekran Görüntüsü**: Mümkünse ekran görüntüsü ekle

## Geliştirme Ortamı Kurulumu

```bash
# Depoyu klonla
git clone https://github.com/bilgiyilmaz33-bot/alpment-os.git
cd alpment-os

# Gerekli araçları yükle
sudo apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin

# ISO oluştur
sudo chmod +x build-iso.sh
sudo ./build-iso.sh
```

## İletişim

Sorularınız veya önerileriniz için lütfen bir issue açın veya discussions bölümüne yazın.

---

Alpment OS projesine katkı sağladığınız için teşekkür ederiz! 🙏
