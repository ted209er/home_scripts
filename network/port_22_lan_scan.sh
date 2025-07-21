#!/bin/bash

for ip in $(nmap -sn 192.168.0.0/24 | awk '/^Nmap scan report for / { print $NF }'); do
    echo -n "Testing $ip ... "
    timeout 2 bash -c "</dev/tcp/$ip/22" 2>/dev/null && echo "SSH open" || echo "No SSH"
done
