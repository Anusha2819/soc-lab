# 🛡️ Home SOC Lab — Security Operations Center on a Budget

> **Built by:** Perikala Anusha | **Platform:** Ubuntu Linux | **RAM:** ~1.4GB Total

A fully functional, RAM-optimised **Security Operations Center (SOC) Lab** running on a home/cloud Linux machine. Detects real threats, ships logs, and visualises everything in Kibana — just like an enterprise SOC.

---

## 📸 Lab Architecture

```
YOUR HOME SOC LAB (RAM-Optimised)
├── Suricata      → Network IDS/IPS        (~200MB RAM)
├── Zeek          → Network Analysis       (~150MB RAM)
├── Wazuh Agent   → Log Collection/SIEM    (~100MB RAM)
├── Elasticsearch → Log Storage            (~512MB RAM)
├── Kibana        → Dashboard/Visualise    (~300MB RAM)
└── Wireshark     → Packet Analysis        (~100MB RAM)
                                    Total: ~1.4GB ✅
```

---

## 🗂️ Repository Structure

```
soc-lab/
├── README.md                        ← You are here
├── scripts/
│   ├── 01_prepare_environment.sh    ← Phase 1: System prep
│   ├── 02_install_suricata.sh       ← Phase 2: Network IDS
│   ├── 03_install_wazuh.sh          ← Phase 3: SIEM Agent
│   ├── 04_install_elk.sh            ← Phase 4: ELK Stack
│   ├── 05_install_filebeat.sh       ← Phase 5: Log shipping
│   ├── 06_simulate_attacks.sh       ← Phase 6: Attack simulations
│   └── full_setup.sh                ← All-in-one installer
├── config/
│   ├── suricata.yaml                ← Suricata config template
│   ├── filebeat.yml                 ← Filebeat config template
│   └── kibana.yml                   ← Kibana config template
├── reports/
│   └── incident_001_port_scan.md    ← Sample incident report
├── screenshots/
│   └── README.md                    ← Screenshot guide
└── docs/
    └── cheatsheet.md                ← SOC analyst cheatsheet
```

---

## 🚀 Quick Start (One Command)

```bash
git clone https://github.com/YOUR_USERNAME/soc-lab.git
cd soc-lab
chmod +x scripts/full_setup.sh
sudo ./scripts/full_setup.sh
```

---

## 📋 Phase-by-Phase Installation

### ✅ Phase 1 — Prepare Environment

```bash
chmod +x scripts/01_prepare_environment.sh
sudo ./scripts/01_prepare_environment.sh
```

**What it does:**
- Updates system packages
- Installs base tools: `curl`, `wget`, `git`, `net-tools`, `nmap`, `python3`
- Checks your network interface name

**Expected output:**
```
[✓] System updated
[✓] Base tools installed
[✓] Network interface: eth0
```

---

### ✅ Phase 2 — Install Suricata (Network IDS)

```bash
chmod +x scripts/02_install_suricata.sh
sudo ./scripts/02_install_suricata.sh
```

**What it does:**
- Installs Suricata IDS/IPS
- Auto-detects your network interface
- Updates threat detection rules
- Starts Suricata as a daemon

**Verify it's running:**
```bash
sudo ps aux | grep suricata
sudo tail -f /var/log/suricata/fast.log
```

---

### ✅ Phase 3 — Install Wazuh Agent (SIEM)

```bash
chmod +x scripts/03_install_wazuh.sh
sudo ./scripts/03_install_wazuh.sh
```

**What it does:**
- Adds the official Wazuh repository
- Installs and configures Wazuh agent
- Connects agent to local manager (127.0.0.1)

**Verify:**
```bash
sudo systemctl status wazuh-agent
```

---

### ✅ Phase 4 — Install ELK Stack

```bash
chmod +x scripts/04_install_elk.sh
sudo ./scripts/04_install_elk.sh
```

**What it does:**
- Installs Java (Elasticsearch dependency)
- Installs Elasticsearch with 512MB RAM cap
- Installs Kibana on port 5601

**Access Kibana:**
```
http://localhost:5601
```

---

### ✅ Phase 5 — Install Filebeat (Log Shipper)

```bash
chmod +x scripts/05_install_filebeat.sh
sudo ./scripts/05_install_filebeat.sh
```

**What it does:**
- Installs Filebeat
- Configures it to ship Suricata + Wazuh logs → Elasticsearch
- Sets up Kibana dashboards automatically

---

### ✅ Phase 6 — Simulate Attacks & Detect Them

```bash
chmod +x scripts/06_simulate_attacks.sh
sudo ./scripts/06_simulate_attacks.sh
```

**Scenarios included:**
| # | Attack Type | Tool Used | Expected Alert |
|---|-------------|-----------|----------------|
| 1 | Port Scan | nmap | ET SCAN Nmap Detected |
| 2 | Ping Flood | ping | ICMP Flood |
| 3 | SSH Brute Force | bash loop | Multiple Failed Logins |

---

## 🖥️ Component Summary

| Component | Role | Port | Status Check |
|-----------|------|------|--------------|
| Suricata | Network IDS/IPS | — | `ps aux \| grep suricata` |
| Wazuh Agent | Log Collection/SIEM | 1514 | `systemctl status wazuh-agent` |
| Elasticsearch | Log Storage/Database | 9200 | `curl localhost:9200` |
| Kibana | Dashboard/Visualisation | 5601 | `systemctl status kibana` |
| Filebeat | Log Forwarder | — | `systemctl status filebeat` |

---

## 📝 Writing SOC Incident Reports

After detecting alerts, document them like a real analyst. See [`reports/incident_001_port_scan.md`](reports/incident_001_port_scan.md) for a full example.

**Report sections:**
- Alert Summary (tool, signature, IPs)
- Timeline of events
- Analysis & verdict
- Response actions taken
- Lessons learned

---

## 🔧 Troubleshooting

| Problem | Fix |
|---------|-----|
| Suricata not starting | Check interface name: `ip link show` |
| Elasticsearch won't start | Check RAM: `free -h`, reduce JVM heap |
| Kibana can't connect | Verify Elasticsearch: `curl localhost:9200` |
| No alerts showing | Run attack simulation: `sudo nmap -sS 127.0.0.1` |
| Filebeat not shipping | Check: `sudo journalctl -u filebeat -f` |

---

## 📚 Resources

- [Suricata Docs](https://suricata.readthedocs.io/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Elastic Stack Docs](https://www.elastic.co/guide/index.html)
- [Emerging Threats Rules](https://rules.emergingthreats.net/)

---

## 👩‍💻 Author

**Perikala Anusha** — Cybersecurity Enthusiast | SOC Analyst in Training

---

## ⭐ Star this repo if it helped you build your own SOC lab!
