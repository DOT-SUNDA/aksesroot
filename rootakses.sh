#!/bin/sh

echo -e "dot\ndot" | passwd root
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
