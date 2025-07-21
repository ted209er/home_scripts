

#!/bin/bash


LOG_FILE="/var/log/network_diag.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

{
  echo "🕓 Timestamp: $TIMESTAMP"
  echo "🔍 Hostname: $(hostname)"
  echo "📡 IP address and interface info:"
  ip addr show | grep -E 'inet |link/ether' | grep -v 'inet6'

  echo -e "\n🌐 Default route:"
  ip route | grep default

  echo -e "\n🔧 DNS Servers:"
  grep "nameserver" /etc/resolv.conf

  echo -e "\n🌎 Public IP:"
  curl -s https://ipinfo.io/ip

  echo -e "\n📶 Ping test:"
  GATEWAY=$(ip route | awk '/default/ { print $3}')
  echo " Gateway ($GATEWAY):"
  ping -c 2 $GATEWAY
  echo -e "\n Google DNS (8.8.8.8):"
  ping -c 2 8.8.8.8

  echo -e "\n🧭 Optional LAN scan (only scans local subnet)"
  SUBNET=$(ip route | grep -oP 'src \K[0-9]+\.[0-9]+\.[0-9]+')
  if [ -n "$SUBNET" ]; then
      nmap -sn "$SUBNET.0/24"
  else
    echo "⚠️ Couldn't auto-detect subnet for scan"
  fi
  echo -e "\n=====================================\n"

} >> "$LOG_FILE" 2>&1


