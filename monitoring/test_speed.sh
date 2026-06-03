#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../scripts/lib/common.sh"

echo "[*] Running internet speed test..."
if ! command -v speedtest &> /dev/null; then
    echo "[*] Installing speedtest-cli..."
    sudo apt update && sudo apt install -y speedtest-cli
fi

DATA_DIR="$(home_scripts_data_dir)"
RESULT_DIR="$DATA_DIR/bandwidth"
mkdir -p "$RESULT_DIR"

TIMESTAMP="$(date '+%Y-%m-%dT%H-%M-%S')"
TEXT_RESULT="$RESULT_DIR/speedtest_$TIMESTAMP.txt"
JSON_RESULT="$RESULT_DIR/speedtest_$TIMESTAMP.json"
LATEST_RESULT="$RESULT_DIR/latest.txt"
LATEST_JSON_RESULT="$RESULT_DIR/latest.json"

if speedtest --help 2>&1 | grep -q -- '--json'; then
    speedtest --json | tee "$JSON_RESULT"
    cp "$JSON_RESULT" "$LATEST_JSON_RESULT"
    echo "[*] JSON result written to $JSON_RESULT"
else
    speedtest | tee "$TEXT_RESULT"
    cp "$TEXT_RESULT" "$LATEST_RESULT"
    echo "[*] Text result written to $TEXT_RESULT"
fi
