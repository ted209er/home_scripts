#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../scripts/lib/common.sh"

DATA_DIR="$(home_scripts_data_dir)"
LOG_DIR="$DATA_DIR/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="${NETWORK_DIAG_LOG_FILE:-$LOG_DIR/network_diag.log}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

{
  echo "Timestamp: $TIMESTAMP"
  echo "Hostname: $(hostname)"
  echo "IP address and interface info:"
  ip addr show | grep -E 'inet |link/ether' | grep -v 'inet6' || true

  echo -e "\nDefault route:"
  ip route | grep default || true

  echo -e "\nDNS Servers:"
  grep "nameserver" /etc/resolv.conf || true

  echo -e "\nPublic IP:"
  if command -v curl >/dev/null 2>&1; then
    curl -s https://ipinfo.io/ip
  else
    echo "curl not installed"
  fi

  echo -e "\nPing test:"
  GATEWAY=$(ip route | awk '/default/ { print $3}')
  echo " Gateway ($GATEWAY):"
  if [ -n "$GATEWAY" ]; then
    ping -c 2 "$GATEWAY" || true
  else
    echo "No default gateway found"
  fi
  echo -e "\n Google DNS (8.8.8.8):"
  ping -c 2 8.8.8.8 || true

  echo -e "\nOptional LAN scan"
  if command -v nmap >/dev/null 2>&1; then
    mapfile -t subnets < <(home_scripts_get_subnets)
    if [ "${#subnets[@]}" -gt 0 ]; then
      for subnet in "${subnets[@]}"; do
        echo -e "\nSubnet: $subnet"
        nmap -sn "$subnet" || true
      done
    else
      echo "Could not auto-detect subnet for scan"
    fi
  else
    echo "nmap not installed; skipping LAN scan"
  fi
  echo -e "\n=====================================\n"

} >> "$LOG_FILE" 2>&1

echo "Network diagnostics written to $LOG_FILE"
