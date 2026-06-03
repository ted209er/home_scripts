#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../scripts/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: latency_check.sh [target ...]

Checks latency and packet loss to the default gateway plus configured or provided targets.
Target priority: command arguments, HOME_LATENCY_TARGETS in config, default public DNS targets.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

home_scripts_load_config
home_scripts_require_command ping

DATA_DIR="$(home_scripts_data_dir)"
RESULT_DIR="$DATA_DIR/latency"
mkdir -p "$RESULT_DIR"

TIMESTAMP="$(date '+%Y-%m-%dT%H-%M-%S')"
RESULT_FILE="$RESULT_DIR/latency_$TIMESTAMP.txt"
PING_COUNT="${HOME_LATENCY_PING_COUNT:-5}"

targets=()
gateway="$(ip route 2>/dev/null | awk '/default/ { print $3; exit }' || true)"
if [ -n "$gateway" ]; then
  targets+=("$gateway")
fi

if [ "$#" -gt 0 ]; then
  targets+=("$@")
elif declare -p HOME_LATENCY_TARGETS >/dev/null 2>&1 && [ "${#HOME_LATENCY_TARGETS[@]}" -gt 0 ]; then
  targets+=("${HOME_LATENCY_TARGETS[@]}")
else
  targets+=("1.1.1.1" "8.8.8.8")
fi

{
  echo "Latency check: $TIMESTAMP"
  echo "Ping count: $PING_COUNT"
  echo
  printf "%-24s %-12s %-12s %-12s %-12s\n" "Target" "Status" "Loss" "Avg ms" "Max ms"

  for target in "${targets[@]}"; do
    ping_output="$(ping -c "$PING_COUNT" "$target" 2>&1 || true)"
    loss="$(awk -F', ' '/packet loss/ { print $3 }' <<<"$ping_output")"
    avg_ms="$(awk -F'/' '/^rtt|^round-trip/ { print $5 }' <<<"$ping_output")"
    max_ms="$(awk -F'/' '/^rtt|^round-trip/ { print $7 }' <<<"$ping_output")"
    status="ok"
    if [ -z "$loss" ]; then
      status="failed"
    elif [ "$loss" != "0% packet loss" ]; then
      status="loss"
    fi

    printf "%-24s %-12s %-12s %-12s %-12s\n" \
      "$target" \
      "$status" \
      "${loss:-unknown}" \
      "${avg_ms:-n/a}" \
      "${max_ms:-n/a}"
  done
} | tee "$RESULT_FILE"

echo
echo "Latency result written to $RESULT_FILE"
