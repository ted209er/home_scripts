#!/bin/bash
set -euo pipefail

echo "[*] Installing Zsh..."
sudo apt update
sudo apt install -y zsh

if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  echo "[*] To make Zsh your login shell, run: chsh -s $(command -v zsh)"
fi

echo "[*] Zsh installed."
