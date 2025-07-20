

#!/bin/bash


echo "[*] Running internet speed test..."
if ! command -v speedtest &> /dev/null; then
    echo "[*] Installing speedtest-cli..."
    sudo apt update && sudo apt install -y speedtest-cli
fi

speedtest | tee speedtest_results.txt
