#!/bin/bash
set -euo pipefail

NODE_EXPORTER_VERSION="${NODE_EXPORTER_VERSION:-1.8.0}"

case "$(uname -m)" in
  armv6l|armv7l) NODE_EXPORTER_ARCH="armv7" ;;
  aarch64|arm64) NODE_EXPORTER_ARCH="arm64" ;;
  x86_64|amd64) NODE_EXPORTER_ARCH="amd64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

archive="node_exporter-${NODE_EXPORTER_VERSION}.linux-${NODE_EXPORTER_ARCH}.tar.gz"
download_url="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${archive}"

echo "[*] Installing Node Exporter ${NODE_EXPORTER_VERSION} for linux-${NODE_EXPORTER_ARCH}..."

cd /tmp
curl -fL -o "$archive" "$download_url"
tar xvf "$archive"
sudo cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-${NODE_EXPORTER_ARCH}/node_exporter" /usr/local/bin/

# Create node_exporter service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable --now node_exporter
sudo systemctl status --no-pager node_exporter
echo "[*] Node Exporter installed and running."
