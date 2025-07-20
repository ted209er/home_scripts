#!/bin/bash

subnet="192.168.86.0/24"
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
