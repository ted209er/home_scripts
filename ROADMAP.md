# Home LAN Administration Roadmap

## Goal

You are the system administrator for your home LAN. This repository should help you answer practical questions quickly:

- What devices are on my network right now?
- Which devices are new, missing, or behaving differently?
- Is an outage caused by my device, Wi-Fi, router, DNS, ISP, or the wider internet?
- Where am I seeing latency, packet loss, or bandwidth drops?
- Which hosts expose risky services such as SSH, SMB, HTTP admin panels, or unexpected ports?
- What changed since the last time things were healthy?

The tools should stay human readable first. Structured output can be added for history and dashboards, but every important script should still produce a clear summary a home admin can understand without reading raw logs.

## Current Direction

This repo is already pointed in the right direction. It contains scripts for network scans, diagnostics, SSH checks, speed tests, host setup, basic hardening, updates, and backups. The next step is to connect those scripts into an operational workflow:

1. Discover assets.
2. Measure health.
3. Record history.
4. Highlight changes.
5. Recommend likely causes and next actions.

## What Should Improve First

### Network Visibility

The repo should build a reliable view of the LAN:

- Known devices by hostname, IP, MAC address, owner, location, and purpose.
- Unknown devices found during scans.
- Devices that were previously present but are now missing.
- Devices whose IP or MAC changed.
- Devices with newly opened or closed ports.

Near-term implementation:

- Keep using `nmap` for host discovery.
- Add `arp-scan` where available because it is good at finding local L2 devices.
- Add an asset config file that lists expected devices and expected services.
- Save every discovery run under `data/scans/`.
- Produce a plain-English summary after each scan.

### Latency and Packet Loss

Latency diagnosis should separate local LAN problems from ISP or internet problems.

The tools should measure:

- Latency to the default gateway.
- Latency to public DNS targets such as `1.1.1.1` and `8.8.8.8`.
- Packet loss to each target.
- Worst-case latency spikes, not just averages.
- Optional traceroute when latency or loss is abnormal.

Near-term implementation:

- Use `network/latency_check.sh` for quick checks.
- Save timestamped results under `data/latency/`.
- Add thresholds later, for example:
  - gateway average above 10 ms,
  - public DNS average above 80 ms,
  - any packet loss above 0 percent.

### Bandwidth and ISP Health

Bandwidth checks should show whether performance issues are temporary, recurring, or tied to time of day.

The tools should track:

- Download speed.
- Upload speed.
- Latency during speed tests.
- Test server used.
- Time of day.
- Recent trend compared to prior tests.

Near-term implementation:

- Keep `monitoring/test_speed.sh`, but save timestamped results under `data/bandwidth/`.
- Prefer JSON output when the installed `speedtest` command supports it.
- Add a weekly summary script later that reports best, worst, and average results.

### Security Exposure

Security checks should focus on what is exposed inside the LAN and what changed.

The tools should identify:

- Hosts with SSH open.
- Hosts with web admin ports open.
- Hosts exposing SMB, RDP, VNC, databases, or other sensitive services.
- Devices with unexpected ports compared to the asset inventory.
- Failed SSH login activity on Linux hosts.
- Whether Fail2Ban and SSH hardening are active.

Near-term implementation:

- Expand `network/port_22_lan_scan.sh` into a broader service exposure scan.
- Add a known-good expected ports list per asset.
- Add `security/audit_host.sh` for local checks:
  - SSH password login disabled,
  - root SSH login disabled,
  - Fail2Ban enabled,
  - pending updates,
  - firewall status.

## Roadmap

### Phase 1: Make Current Tools Reliable

Goal: scripts should be safe, repeatable, and predictable.

Work:

- Keep network ranges config-driven.
- Keep generated results under `data/`.
- Add help text to every script.
- Run ShellCheck regularly.
- Avoid scripts that silently write into the current directory.
- Make setup scripts idempotent where possible.

Outcome:

- You can run the scripts from any location and understand where the output went.
- The repo behaves consistently across Raspberry Pis and Linux laptops.

### Phase 2: Create the Asset Inventory

Goal: distinguish known devices from unknown devices.

Work:

- Add `config/assets.example.yml`.
- Track device name, IP, MAC, owner, location, role, and expected ports.
- Add `inventory/reconcile_assets.sh`.
- Report:
  - new devices,
  - missing devices,
  - changed IPs,
  - changed MAC addresses,
  - unexpected open ports.

Outcome:

- A scan tells you what changed, not just what exists.

### Phase 3: Add Health History

Goal: turn one-off checks into useful history.

Work:

- Save scan results in timestamped files.
- Save latency results in timestamped files.
- Save bandwidth results in timestamped files.
- Add simple summary scripts for the last day, week, and month.

Outcome:

- You can tell whether today is worse than normal.
- You can spot recurring ISP or Wi-Fi performance patterns.

### Phase 4: Add Monitoring Dashboards

Goal: make the LAN observable without manually running every script.

Work:

- Add Prometheus and Grafana with Docker Compose.
- Use Node Exporter for Linux and Raspberry Pi hosts.
- Use Blackbox Exporter for ping, HTTP, TCP, and DNS checks.
- Use SNMP Exporter for routers, switches, printers, or UPS devices when supported.
- Add dashboards for:
  - device availability,
  - gateway and DNS health,
  - bandwidth trend,
  - latency trend,
  - Raspberry Pi CPU, memory, disk, and temperature,
  - exposed services.

Outcome:

- You can open one dashboard and see LAN health at a glance.

### Phase 5: Add Alerts

Goal: know about important changes before they become mysteries.

Work:

- Alert when the gateway is unreachable.
- Alert when internet targets are unreachable.
- Alert when packet loss appears.
- Alert when a critical device disappears.
- Alert when an unknown device appears.
- Alert when a sensitive port appears unexpectedly.
- Alert when a Pi has high temperature, disk pressure, or pending updates.

Outcome:

- Alerts are tied to actionable events, not noisy raw data.

## Suggested Tooling

Use these tools because they fit the repo and the job:

- `nmap`: host discovery and service scans.
- `arp-scan`: local device discovery by MAC address.
- `ping`: fast latency and packet-loss checks.
- `traceroute` or `mtr`: path diagnosis when latency is abnormal.
- `speedtest`: bandwidth checks.
- `jq`: parse JSON results.
- `yq`: read YAML inventory files.
- SQLite: small local history database when flat files become too limited.
- Prometheus: metrics collection.
- Grafana: dashboards.
- Alertmanager or ntfy: actionable notifications.
- ShellCheck: script quality.

## First Practical Sprint

1. Add `config/assets.example.yml`.
2. Extend LAN discovery to save timestamped scan results.
3. Add a human-readable change report.
4. Expand SSH-only scanning into a sensitive-port scan.
5. Add local host security audit output.
6. Add monthly bandwidth and latency summaries.
7. Add Docker Compose for Prometheus, Grafana, and Blackbox Exporter.

## Success Criteria

The repo is succeeding when you can answer these questions quickly:

- What is on my LAN?
- What changed since yesterday?
- Is the problem local, router-side, ISP-side, or internet-side?
- Which devices are exposing services?
- Which assets are offline?
- Is bandwidth worse than usual?
- Is latency worse than usual?
- What should I check next?
