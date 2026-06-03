#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../scripts/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: scan_lan.sh [subnet ...]

Scans configured or auto-detected LAN subnets with nmap ping discovery.
Subnet priority: command arguments, config/home_network.conf, auto-detected routes.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

home_scripts_require_command nmap

mapfile -t subnets < <(home_scripts_get_subnets "$@")
if [ "${#subnets[@]}" -eq 0 ]; then
  echo "No LAN subnets configured or detected." >&2
  exit 1
fi

for subnet in "${subnets[@]}"; do
  echo "Scanning LAN $subnet"
  nmap -sn "$subnet" | awk '
    /^Nmap scan report for / {
      host = $0
      ip = $NF
      sub(/Nmap scan report for /, "", host)
      getline
      getline
      if ($0 ~ /MAC Address:/) {
        mac = $3
        vendor = substr($0, index($0,$4))
      } else {
        mac = "N/A"
        vendor = "N/A"
      }
      printf "%-40s %-16s %-20s %s\n", host, ip, mac, vendor
    }'
done
