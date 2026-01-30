#!/bin/sh

echo "root:Dotaja123@HHHH" | chpasswd
wget -qO /etc/ssh/sshd_config https://raw.githubusercontent.com/DOT-SUNDA/aksesroot/refs/heads/main/sshd_config
systemctl restart sshd
public_ip=$(curl -s ifconfig.me)
echo "===================================="
printf "%-30s\n" "DOT AJA"
echo "===================================="
echo "AKSES SSH : ssh root@$public_ip:22"
echo "PASSWORD : dot"
echo "===================================="
echo "AKSES SSH"
echo "COPY DAN PASTEKAN KE PUTTY"
echo "===================================="

# ==========================================
# 1. EDIT DATA ANDA DI SINI DULU BOSKU !!!
# ==========================================
MY_DOMAIN="turnimon.com"
MY_TOKEN="123456789:AAHzxxxxxxxxxxxxxxxxxxxx"
MY_CHATID="12345678"
# ==========================================

# Hapus script lama
rm -f /root/auto_cs.sh

# Membuat File Script Utama
cat <<EOF > /root/auto_cs.sh
#!/bin/bash

# --- KONFIGURASI ---
DOMAIN="${MY_DOMAIN}"
TG_TOKEN="${MY_TOKEN}"
TG_CHATID="${MY_CHATID}"

# Jumlah akun PER SERVER (Jadi total nanti dikali 3)
JUMLAH_PER_SERVER=3

# Daftar API URL (Berurutan)
URLS=(
    "https://mnl.cloudsigma.com/api/2.0/accounts/action/?do=create"
    "https://crk.cloudsigma.com/api/2.0/accounts/action/?do=create"
    "https://cai.cloudsigma.com/api/2.0/accounts/action/?do=create"
)

# Fungsi Kirim Telegram
send_tg() {
    curl -s -X POST "https://api.telegram.org/bot\${TG_TOKEN}/sendMessage" \
        -d chat_id="\${TG_CHATID}" \
        -d text="\$1" \
        -d parse_mode="HTML" > /dev/null
}

echo "=== STARTING SEQUENTIAL CREATE (MNL -> CRK -> CAI) ==="

# LOOP 1: Untuk setiap URL Server
for URL in "\${URLS[@]}"; do
    
    # Ambil Nama Server (MNL/CRK/CAI) untuk laporan
    SERVER_NAME=\$(echo \$URL | cut -d'/' -f3 | cut -d'.' -f1 | tr 'a-z' 'A-Z')
    
    echo ">> Pindah ke Server: \$SERVER_NAME"

    # LOOP 2: Membuat akun sesuai jumlah yang diminta (3 akun)
    for ((i=1; i<=JUMLAH_PER_SERVER; i++)); do
        
        # Buat Email Random
        RAND_USER=\$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)
        EMAIL="\${RAND_USER}@\${DOMAIN}"
        LINK_INBOX="https://tempm.com/\${EMAIL}"

        echo "   [\$i/\$JUMLAH_PER_SERVER] Creating \$EMAIL ..."

        # Tembak API
        RESPONSE=\$(curl -s -X POST "\$URL" \
            -H "Content-Type: application/json" \
            -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64)" \
            -d "{\"email\":\"\${EMAIL}\",\"promo\":null}")

        # Cek Hasil
        if [[ \$RESPONSE == *"uuid"* ]]; then
            UUID=\$(echo \$RESPONSE | grep -o '"uuid":"[^"]*"' | cut -d'"' -f4)
            
            MSG="<b>✅ SUKSES - \$SERVER_NAME</b>%0A(Akun ke-\$i)%0A%0A📧 <code>\${EMAIL}</code>%0A🔗 <a href=\"\${LINK_INBOX}\">Buka Inbox</a>%0A🆔 UUID: <code>\${UUID}</code>"
            
            send_tg "\$MSG"
        else
            echo "   -> Gagal/Error."
        fi
        
        # Jeda 2 detik antar akun
        sleep 2
    done
    
    # Jeda 3 detik saat pindah server
    sleep 3
done

EOF

# Beri Izin Eksekusi
chmod +x /root/auto_cs.sh

# Pasang Auto Boot (Cronjob) - Delay 10 Detik
(crontab -l 2>/dev/null | grep -v "auto_cs.sh") | crontab -
(crontab -l 2>/dev/null; echo "@reboot sleep 10 && /root/auto_cs.sh") | crontab -

echo "============================================="
echo "✅ BERHASIL DIINSTALL BOSKU!"
echo "---------------------------------------------"
echo "Logika Script:"
echo "1. Server MNL -> Bikin 3 Akun"
echo "2. Server CRK -> Bikin 3 Akun"
echo "3. Server CAI -> Bikin 3 Akun"
echo "Total = 9 Akun otomatis saat Boot."
echo "============================================="
