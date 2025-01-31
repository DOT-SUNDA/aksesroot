#!/bin/bash

# Memastikan utilitas yang dibutuhkan ada
if ! command -v curl &>/dev/null || ! command -v cat &>/dev/null || ! command -v base64 &>/dev/null || ! command -v tr &>/dev/null; then
  echo "Menginstal dependensi yang diperlukan..."
  apt-get update
  apt-get install -y coreutils curl gnupg
fi

# Memastikan V2Ray sudah terpasang, jika belum, instal V2Ray
if ! command -v v2ray &>/dev/null; then
  echo "V2Ray tidak ditemukan, menginstal V2Ray..."
  bash <(curl -s -L https://git.io/v2ray.sh)
else
  echo "V2Ray sudah terpasang."
fi

# Generate a random UUID
UUID=$(uuidgen)

# Path WebSocket
PATH="/vmess"  # Path WebSocket yang telah disesuaikan

# Backup existing config.json if exists
if [ -f /etc/v2ray/config.json ]; then
  cp /etc/v2ray/config.json /etc/v2ray/config.json.bak
fi

# Replace config.json with WebSocket NTLS (Port 80) and WebSocket TLS (Port 443) configuration
cat << EOF > /etc/v2ray/config.json
{
  "inbounds": [
    {
      "port": 80,
      "listen": "0.0.0.0",
      "protocol": "vmess",
      "settings": {
        "clients": [{
          "id": "$UUID",
          "alterId": 64,
          "security": "auto"
        }]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$PATH"
        }
      }
    },
    {
      "port": 443,
      "listen": "0.0.0.0",
      "protocol": "vmess",
      "settings": {
        "clients": [{
          "id": "$UUID",
          "alterId": 64,
          "security": "auto"
        }]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$PATH"
        },
        "security": "tls"
      }
    }
  ],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }],
  "routing": {
    "rules": [{
      "type": "field",
      "outboundTag": "blocked",
      "domain": [
        "geosite:cn"
      ]
    }]
  },
  "dns": {
    "servers": ["8.8.8.8", "8.8.4.4"]
  }
}
EOF

# Restart v2ray to apply the changes
systemctl restart v2ray

# Generate VMess URL for Port 80 (NTLS)
DOMAIN="vmess.dot-aja.my.id"  # Ganti dengan domain Anda
VMESS_JSON_80=$(cat << EOF
{
  "v": "2",
  "ps": "V2Ray WebSocket No-TLS",
  "add": "$DOMAIN",
  "port": "80",
  "id": "$UUID",
  "aid": 64,
  "net": "ws",
  "type": "none",
  "host": "",
  "path": "$PATH",
  "tls": ""
}
EOF
)

# Generate VMess URL for Port 443 (TLS)
VMESS_JSON_443=$(cat << EOF
{
  "v": "2",
  "ps": "V2Ray WebSocket with TLS",
  "add": "$DOMAIN",
  "port": "443",
  "id": "$UUID",
  "aid": 64,
  "net": "ws",
  "type": "none",
  "host": "",
  "path": "$PATH",
  "tls": "tls"
}
EOF
)

# Encode VMess JSON to base64
VMESS_BASE64_80=$(echo -n $VMESS_JSON_80 | base64 | tr -d '\n')
VMESS_BASE64_443=$(echo -n $VMESS_JSON_443 | base64 | tr -d '\n')

# Output VMess URLs
echo "VMess URL for Port 80 (No-TLS):"
echo "vmess://$VMESS_BASE64_80"
echo ""
echo "VMess URL for Port 443 (TLS):"
echo "vmess://$VMESS_BASE64_443"
