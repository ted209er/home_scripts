

#!/bin/bash


SSH_CONF="/etc/ssh/sshd_config"

echo "[*] Backing up SSH config..."
sudo cp "$SSH_CONF" "${SSH_CONF}.bak"

echo "[*] Hardening SSH..."
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONF"
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONF"
sudo sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSH_CONF"

echo "[*] Restarting SSH..."
sudo systemctl restart ssh

echo "[*] SSH hardening applied."
