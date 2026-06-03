# Home Network and Asset Monitoring Roadmap

## Intent

This repository is a portable home administration toolkit for Raspberry Pis, Linux hosts, and local network maintenance. The current scripts focus on setup, security hardening, basic network scans, diagnostics, speed tests, backups, and update checks.

The next phase should turn the repo into a lightweight home network operations toolkit: discover every asset on the LAN, track what changed, monitor host and service health, alert on important events, and keep enough history to troubleshoot outages.

## Current State

### Existing Strengths

- Clear directory split for `setup/`, `network/`, `monitoring/`, `security/`, and `utils/`.
- Useful first-pass scripts for LAN scanning, SSH port checks, traceroute, local diagnostics, node exporter setup, speed tests, Fail2Ban, SSH hardening, updates, and SD card backups.
- Repo is small enough to standardize quickly without a large refactor.

### Gaps to Address

- Script output is mostly human text, which makes history, diffs, dashboards, and alerting harder.
- There is no source of truth for known assets, owners, roles, expected ports, or expected status.
- There is no change detection for new devices, missing devices, changed MAC addresses, or newly exposed services.
- Monitoring is not yet tied together with Prometheus, Grafana, alerting, or recurring jobs.
- Several scripts still write results into the current directory instead of a predictable data path.

## Guiding Principles

- Keep shell scripts for simple host administration tasks.
- Add structured output for anything that will be tracked over time.
- Prefer configuration files over hard-coded local assumptions.
- Make scripts safe to run repeatedly.
- Build toward observable state: inventory, metrics, logs, alerts, and dashboards.
- Keep private local details, secrets, and credentials out of Git.

## Recommended Repo Structure

```text
config/
  home_network.example.yml
  assets.example.yml
docs/
  dashboards.md
  operations.md
inventory/
  README.md
network/
  discover_assets.sh
  scan_services.sh
monitoring/
  prometheus/
  grafana/
  alertmanager/
scripts/
  lib/
    common.sh
    config.sh
    logging.sh
systemd/
  home-network-discovery.service
  home-network-discovery.timer
ROADMAP.md
```

## Recommended Tooling

### Discovery and Inventory

- `nmap` for host discovery and service scans.
- `arp-scan` for local Ethernet/Wi-Fi MAC discovery.
- `avahi-browse` for mDNS device visibility.
- `dig` and `nslookup` for DNS validation.
- `jq` and `yq` for structured JSON/YAML processing.
- SQLite for a small local asset and scan-history database.

### Monitoring

- Prometheus for metrics collection.
- Grafana for dashboards.
- Node Exporter for Linux host metrics.
- Blackbox Exporter for ping, HTTP, TCP, and DNS probes.
- Speedtest Exporter or scheduled speedtest JSON output for ISP trend tracking.
- SNMP Exporter where supported by routers, switches, UPS units, or printers.

### Alerting

- Alertmanager for Prometheus alerts.
- ntfy, Pushover, Gotify, Discord, Slack, or email for home-admin notifications.
- Fail2Ban logs and SSH auth logs as security alert sources.

### Automation

- systemd timers for recurring scans and health checks.
- Docker Compose for Prometheus, Grafana, Alertmanager, and exporters.
- ShellCheck for script quality.
- `bats-core` for shell-script tests where behavior matters.

## Feature Roadmap

### Phase 1: Stabilize the Current Toolkit

- Add a shared `scripts/lib/common.sh` with:
  - strict shell settings,
  - dependency checks,
  - timestamp helpers,
  - output directory handling,
  - consistent error messages.
- Continue moving network assumptions into config values with auto-detection fallback.
- Normalize output paths under `data/` or `/var/lib/home-scripts/`.
- Add `--help` support to scripts that take arguments.
- Keep setup and maintenance scripts idempotent as they evolve.
- Add ShellCheck to local validation.

Suggested deliverables:

- `config/home_network.example.yml`
- `scripts/lib/common.sh`
- `network/scan_lan.sh` outputs both table text and JSON
- `Makefile` targets for `lint`, `test`, and `scan`

### Phase 2: Build the Asset Inventory

- Define an asset schema with:
  - hostname,
  - IP address,
  - MAC address,
  - vendor,
  - device type,
  - owner,
  - location,
  - role,
  - expected open ports,
  - monitoring profile,
  - notes.
- Add a discovery script that writes scan results to JSON.
- Add a reconciliation command that compares discovered devices to known assets.
- Flag:
  - new devices,
  - missing devices,
  - changed MAC or IP addresses,
  - unexpected SSH exposure,
  - unexpected open ports.

Suggested deliverables:

- `config/assets.example.yml`
- `network/discover_assets.sh`
- `inventory/reconcile_assets.sh`
- `data/scans/YYYY-MM-DDTHH-MM-SS.json`

### Phase 3: Deploy Metrics and Dashboards

- Add Docker Compose for Prometheus, Grafana, Alertmanager, Blackbox Exporter, and optional exporters.
- Generate Prometheus scrape targets from inventory config.
- Add dashboards for:
  - internet health,
  - device availability,
  - Raspberry Pi CPU, memory, disk, and temperature,
  - SSH exposure,
  - DNS and gateway health,
  - speedtest history,
  - asset count and change events.
- Add node exporter installation that detects architecture and validates systemd status.

Suggested deliverables:

- `monitoring/docker-compose.yml`
- `monitoring/prometheus/prometheus.yml`
- `monitoring/blackbox/blackbox.yml`
- `monitoring/grafana/dashboards/`
- corrected `monitoring/install_node_exporter.sh`

### Phase 4: Alerting and Change Detection

- Alert when the gateway, DNS, or internet target is unavailable.
- Alert when a critical asset is offline.
- Alert when a new unknown device appears.
- Alert when a sensitive port opens on an unexpected device.
- Alert when disk, CPU, memory, temperature, or update status crosses thresholds.
- Send daily or weekly summaries to the home admin.

Suggested deliverables:

- `monitoring/alertmanager/alertmanager.yml`
- `monitoring/prometheus/rules/`
- `network/report_changes.sh`
- `systemd/home-network-discovery.timer`

### Phase 5: Security and Maintenance

- Add host hardening checks instead of only one-way hardening changes.
- Track SSH configuration, Fail2Ban status, pending updates, and open ports.
- Add backup verification for SD card images.
- Add log rotation guidance for generated files.
- Add a local operations guide for restoring monitoring services after a Pi reboot or SD card failure.

Suggested deliverables:

- `security/audit_host.sh`
- `utils/verify_backup.sh`
- `docs/operations.md`
- `docs/security-baseline.md`

## Example Asset Schema

```yaml
assets:
  - name: blueberry-pi
    type: raspberry-pi
    owner: home-admin
    location: network-shelf
    role: monitoring
    ip: 192.168.86.10
    mac: "00:00:00:00:00:00"
    expected_ports:
      - 22
      - 9100
    monitor:
      ping: true
      node_exporter: true
      blackbox_tcp:
        - 22
```

## Suggested First Implementation Sprint

1. Fix current script bugs.
2. Add `config/home_network.example.yml`.
3. Extend `network/scan_lan.sh` to emit JSON.
4. Add `config/assets.example.yml`.
5. Add an inventory reconciliation script that reports unknown, missing, and changed devices.
6. Add ShellCheck and a simple validation command.
7. Document the expected local config file names and keep real local config ignored by Git.

## Success Criteria

- The home admin can run one command and see every currently discovered LAN device.
- Known assets are tracked separately from unknown devices.
- Device changes are visible without manually reading full scan output.
- Critical assets and services can be monitored continuously.
- Dashboards show internet health, host health, and asset status.
- Alerts identify actionable events instead of raw scan noise.
