# 🛠️ home_scripts

Central repo for maintaining Raspberry Pi and home network setup scripts.

## Structure

- `setup/` - Scripts for initial configuration (zsh, Docker, Vim, etc.)
- `network` - Tools for scanning, identifying, tracing devices
- `monitoring` - Setup scripts for exporters and tests
- `security` - Hardening my Pis and local devices
- `utils/` - Backup and update utilities


## Usage

Clone to any Pi or laptop:
```bash
git clone git@github.com:ted209er/home_scripts.git
cd home_scripts
```

### Run a script
```bash
bash setup/install_docker.sh
```

### Network configuration

Network scripts discover directly connected IPv4 subnets automatically. To pin the subnets that should be scanned, copy the example config and edit it:

```bash
cp config/home_network.conf.example config/home_network.conf
```

You can also pass a subnet directly:

```bash
network/scan_lan.sh 192.168.86.0/24
network/port_22_lan_scan.sh 192.168.86.0/24
```

## Additions Coming Soon

- Mesh monitoring hooks
- Grafana dashboards
- Weather and alert triggers


---



## 📡 2. Your Pi-Modem-Spectrum Setup & Telemetry Strategy



### 🔌 Topology Summary (based on your notes)



```plaintext

[ Modem (Bable Internet) ]

          │

    [Spectrum Router]

        ├─ Wife's Dell Dock

        ├─ Google Wifi Mesh Point

        └─ Blueberry Pi
```
