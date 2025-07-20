#!/bin/bash

TARGET=${1:-8.8.8.8}
echo "[*] Tracing route to $TARGET..."
traceroute "$TARGET" | tee trace_route_results.txt
