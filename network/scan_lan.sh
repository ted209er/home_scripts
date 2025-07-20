#!/bin/bash

# Scan the local subnet for active hosts
echo "[*] Scanning LAN for active devices..."
subnet=$(ip route | grep -m1 src | awk '{print $1}')
nmap -sn "$subnet" -oG - | awk '/Up$/{print $2}' | tee lan_scan_results.txt
echo "[*] Results saved to lan_scan_results.txt"

