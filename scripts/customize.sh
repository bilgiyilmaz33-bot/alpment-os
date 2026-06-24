#!/bin/bash

# Alpment OS 0.1 - Özelleştirme Scripti
# Bu script Alpment OS'u kişiselleştirmenize yardımcı olur

echo "================================"
echo "Alpment OS 0.1 - Özelleştirme Aracı"
echo "================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    echo -e "${BLUE}Lütfen seçim yapınız:${NC}"
    echo "1. Tema değiştir (Açık/Koyu)"
    echo "2. İkonları değiştir"
    echo "3. Duvar kağıdını değiştir"
    echo "4. Yazı tipini değiştir"
    echo "5. Masaüstü simgelerini göster/gizle"
    echo "6. Başlat menüsü konumunu değiştir"
    echo "7. Performans ayarları"
    echo "8. Çıkış"
    echo ""
}

while true; do
    show_menu
    read -p "Seçiminiz: " choice
    
    case $choice in
        1)
            echo "Tema değiştiriliyoru..."
            dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'" 2>/dev/null || echo "Tema uygulanıyor..."
            echo -e "${GREEN}Tema değiştirildi!${NC}"
            ;;
        2)
            echo "İkon teması değiştiriliyoru..."
            dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'" 2>/dev/null || echo "İkonlar uygulanıyor..."
            echo -e "${GREEN}İkonlar değiştirildi!${NC}"
            ;;
        3)
            echo "Duvar kağıdı değiştiriliyoru..."
            dconf write /org/gnome/desktop/background/picture-uri "'file:///usr/share/backgrounds/alpment/default.png'" 2>/dev/null
            echo -e "${GREEN}Duvar kağıdı değiştirildi!${NC}"
            ;;
        4)
            read -p "Yazı tipi adını girin (örn. 'DejaVu Sans 12'): " font
            dconf write /org/gnome/desktop/interface/font-name "'$font'" 2>/dev/null
            echo -e "${GREEN}Yazı tipi değiştirildi!${NC}"
            ;;
        5)
            read -p "Masaüstü simgelerini göster? (e/h): " show_icons
            if [ "$show_icons" = "e" ]; then
                dconf write /org/gnome/desktop/gnome-settings-daemon/plugins/power/active true 2>/dev/null
                echo -e "${GREEN}Simgeler gösterilecek!${NC}"
            else
                dconf write /org/gnome/desktop/gnome-settings-daemon/plugins/power/active false 2>/dev/null
                echo -e "${GREEN}Simgeler gizlenecek!${NC}"
            fi
            ;;
        6)
            echo "Başlat menüsü konumu değiştiriliyoru..."
            dconf write /org/gnome/shell/extensions/dash-to-panel/panel-position "'BOTTOM'" 2>/dev/null || true
            echo -e "${GREEN}Başlat menüsü en altaya taşındı!${NC}"
            ;;
        7)
            echo "Performans ayarları:"
            echo "1. Animasyonları kapat (daha hızlı)"
            echo "2. Animasyonları aç (daha güzel)"
            read -p "Seçiminiz (1/2): " perf_choice
            if [ "$perf_choice" = "1" ]; then
                dconf write /org/gnome/desktop/interface/enable-animations false 2>/dev/null
                echo -e "${GREEN}Animasyonlar kapatıldı (daha hızlı)${NC}"
            else
                dconf write /org/gnome/desktop/interface/enable-animations true 2>/dev/null
                echo -e "${GREEN}Animasyonlar açıldı${NC}"
            fi
            ;;
        8)
            echo -e "${GREEN}Çıkılıyor...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Geçersiz seçim!${NC}"
            ;;
    esac
    
    echo ""
    read -p "Devam etmek için Enter tuşuna basın..."
    clear
done

echo -e "${GREEN}Özelleştirme aracından çıkıldı.${NC}"
