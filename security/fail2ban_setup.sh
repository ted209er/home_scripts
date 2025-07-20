

#!/bin/bash


echo "[*] Installing Fail2Ban..."
sudo apt update && sudo apt install -y fail2ban

echo "[*] Enabling and starting Fail2Ban..."
sudo systemctl enable --now fail2ban

echo "[*] Fail2Ban status:"
sudo fail2ban-client status sshd || echo "No sshd jail yet, configure /etc/fail2ban/jail.local as needed."

