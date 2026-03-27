# 🛡️ SOC Lab — Analyst Cheatsheet

Quick reference for common commands used in the SOC Lab.

---

## 🔍 Suricata

```bash
# Check if running
sudo ps aux | grep suricata

# Watch live alerts
sudo tail -f /var/log/suricata/fast.log

# Watch full JSON events
sudo tail -f /var/log/suricata/eve.json | jq .

# Filter for specific alert type
sudo grep "SCAN" /var/log/suricata/fast.log

# Filter for specific IP
sudo grep "192.168.1.100" /var/log/suricata/fast.log

# Restart Suricata
sudo systemctl restart suricata

# Test config
sudo suricata -T -c /etc/suricata/suricata.yaml

# Update rules
sudo suricata-update
```

---

## 🔐 Wazuh Agent

```bash
# Status
sudo systemctl status wazuh-agent

# Live agent log
sudo tail -f /var/ossec/logs/ossec.log

# Live alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log

# Restart agent
sudo systemctl restart wazuh-agent

# Check config
sudo cat /var/ossec/etc/ossec.conf
```

---

## 📊 Elasticsearch

```bash
# Check if up
curl http://localhost:9200

# View cluster health
curl http://localhost:9200/_cluster/health?pretty

# List indices
curl http://localhost:9200/_cat/indices?v

# Search Suricata index
curl "http://localhost:9200/filebeat-*/_search?q=tags:suricata&size=5&pretty"

# Check disk usage
curl http://localhost:9200/_cat/allocation?v
```

---

## 📦 Filebeat

```bash
# Status
sudo systemctl status filebeat

# Live log
sudo journalctl -u filebeat -f

# Test config
sudo filebeat test config

# Test output connection
sudo filebeat test output

# Restart
sudo systemctl restart filebeat
```

---

## 💥 Attack Simulation Commands

```bash
# Port scan
sudo nmap -sS 127.0.0.1

# Aggressive scan (more alerts)
sudo nmap -A 127.0.0.1

# Ping flood
ping -c 100 -i 0.05 127.0.0.1

# SSH brute force simulation
for i in {1..10}; do ssh -o ConnectTimeout=2 -o BatchMode=yes fakeuser@localhost 2>/dev/null; done

# Check what was detected
sudo grep "Failed password" /var/log/auth.log | tail -20
sudo tail -20 /var/log/suricata/fast.log
```

---

## 🖥️ System Monitoring

```bash
# RAM usage
free -h

# CPU + processes
htop

# Disk usage
df -h

# All SOC services at once
for svc in suricata wazuh-agent elasticsearch kibana filebeat; do
  echo "$svc: $(systemctl is-active $svc 2>/dev/null || echo 'not a service')"
done
```

---

## 🌐 Kibana Quick Nav

| What to do | Where to go |
|------------|-------------|
| See all logs | Discover → filebeat-* |
| Suricata alerts | Discover → filter: tags: suricata |
| Auth failures | Discover → filter: tags: auth |
| Network dashboard | Dashboard → [Filebeat Suricata] Overview |
| Create alert rule | Stack Management → Rules |

---

## 📝 Incident Severity Guide

| Severity | Colour | Examples |
|----------|--------|---------|
| Critical | 🔴 | Active exploitation, data exfil, ransomware |
| High | 🟠 | Brute force success, malware detected |
| Medium | 🟡 | Port scan, multiple failed logins |
| Low | 🔵 | Single failed login, ping sweep |
| Info | ⚪ | Policy violation, unusual time of access |

---

## 📋 Incident Report Template

```markdown
# Incident Report — IR-XXX

**Date:** YYYY-MM-DD  
**Analyst:** Your Name  
**Severity:** [Critical/High/Medium/Low]

## Alert Summary
Tool: [Suricata/Wazuh/Manual]
Alert: [Signature name]
Source IP: x.x.x.x
Destination: x.x.x.x

## Timeline
HH:MM UTC — Event 1
HH:MM UTC — Alert triggered
HH:MM UTC — Investigation started

## Analysis
[What happened and why]

## Response
[Actions taken]

## Lessons Learned
[What worked, what to improve]
```
