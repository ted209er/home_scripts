#!/bin/bash
set -euo pipefail

echo "[*] Installing Docker..."
if command -v docker >/dev/null 2>&1; then
  docker --version
  echo "[*] Docker is already installed."
  exit 0
fi

curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

echo "[*] Docker installed. Log out and back in for docker group membership to apply."
