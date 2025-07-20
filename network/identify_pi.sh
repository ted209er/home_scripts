#!/bin/bash

echo "🔎 Identifying Raspberry Pi..."

# Hostname
echo -e "\n📛 Hostname: $(hostname)"k

# Os + Version
echo -e "\n🧠 OS Info:"
cat /etc/os-release | grep PRETTY_NAME

# Model & SoC
echo -e "\n 💻 Hardware Info:"
if [ -f /proc/cpuinfo ]; then
    grep -E 'Hardware|Revision|Model' /proc/cpuinfo
fi

# CPU Details
echo -e "\n⚙️ CPU:"
lscpu | grep 'Model name\|CPU MHz\|Architecture'

# RAM
echo -e "\n💾 Memory:"
free -h

# Disk
echo -e "\n🗄️ Disk:"
df -h /

# Network
echo -e "\n🌐 IP Address:"
hostname -I

# Ethernet Interface
echo -e "\n 🔌 Interfaces:"
ip -o link show | awk -F': ' '{print $2}' | grep -E '^eth|^en'

# Uptime
echo -e "\n Uptime:"
uptime -p

echo -e "\n✅ Done.\n"
