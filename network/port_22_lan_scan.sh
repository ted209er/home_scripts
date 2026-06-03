#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../scripts/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: port_22_lan_scan.sh [subnet ...]

Discovers hosts in configured or provided subnets, then checks TCP/22.
Subnet priority: command arguments, config/home_network.conf, auto-detected routes.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

home_scripts_require_command nmap
home_scripts_require_command timeout

mapfile -t subnets < <(home_scripts_get_subnets "$@")
if [ "${#subnets[@]}" -eq 0 ]; then
  echo "No LAN subnets configured or detected." >&2
  exit 1
fi

for subnet in "${subnets[@]}"; do
  echo "Scanning $subnet for hosts with SSH open"
  while read -r ip; do
    [ -n "$ip" ] || continue
    echo -n "Testing $ip ... "
    timeout 2 bash -c "</dev/tcp/$ip/22" 2>/dev/null && echo "SSH open" || echo "No SSH"
  done < <(nmap -sn "$subnet" | awk '/^Nmap scan report for / { print $NF }')
done
