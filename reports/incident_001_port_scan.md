# Incident Report — IR-001

| Field      | Value                          |
|------------|-------------------------------|
| **Date**   | 2026-03-27                    |
| **Time**   | 05:58 UTC                     |
| **Analyst**| Perikala Anusha               |
| **Severity**| 🟡 Medium                    |
| **Status** | Closed — Self-test            |

---

## 1. Alert Summary

| Item            | Detail                                  |
|-----------------|-----------------------------------------|
| **Tool**        | Suricata IDS                            |
| **Signature**   | ET SCAN Nmap Scripting Engine User-Agent Detected |
| **Source IP**   | 127.0.0.1 (localhost)                   |
| **Destination** | 127.0.0.1 (localhost)                   |
| **Protocol**    | TCP                                     |
| **Ports**       | 1–1000                                  |

---

## 2. Timeline

```
05:58:01 UTC — Port scan initiated via: nmap -sS 127.0.0.1
05:58:01 UTC — Suricata alert triggered: ET SCAN Nmap detected
05:58:01 UTC — 1000 ports scanned in 0.11 seconds
05:58:01 UTC — 0 open ports found — no successful connection
05:58:02 UTC — Alert logged to /var/log/suricata/fast.log
```

---

## 3. Alert Evidence

**Suricata fast.log entry:**
```
03/27/2026-05:58:01.234521  [**] [1:2009582:5] ET SCAN Nmap Scripting Engine User-Agent Detected (Nmap Scripting Engine) [**] [Classification: Web Application Attack] [Priority: 1] {TCP} 127.0.0.1:44321 -> 127.0.0.1:80
```

**Nmap output:**
```
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000088s latency).
All 1000 scanned ports on localhost (127.0.0.1) are closed
Nmap done: 1 IP address (1 host up) scanned in 0.11 seconds
```

---

## 4. Analysis

**What happened:**  
A TCP SYN (stealth) scan was performed against localhost using Nmap. This scan sends SYN packets to each port and listens for SYN-ACK (open) or RST (closed) responses without completing the three-way handshake, making it harder to detect by basic logging.

**Verdict:**  
✅ Benign — self-test conducted as part of SOC lab Phase 6 simulation.

**In a real environment:**  
This pattern would indicate reconnaissance. An attacker mapping open services before launching an exploit. Immediate investigation of the source IP would be required.

---

## 5. Response Actions

| Action | Status |
|--------|--------|
| Confirmed alert in Suricata fast.log | ✅ Done |
| Verified no open ports were found | ✅ Done |
| Checked auth.log for concurrent activity | ✅ Done — clean |
| Block source IP at firewall | ⚠️ N/A (self-test) |
| Escalate to Tier 2 | ⚠️ N/A (self-test) |

---

## 6. MITRE ATT&CK Mapping

| Tactic        | Technique                  | ID          |
|---------------|----------------------------|-------------|
| Reconnaissance| Active Scanning            | T1595       |
| Discovery     | Network Service Scanning   | T1046       |

---

## 7. Lessons Learned

- ✅ Suricata successfully detected a stealth SYN scan against localhost
- ✅ Alert appeared in fast.log within 1 second of scan start
- ✅ Alert shipped to Elasticsearch via Filebeat and visible in Kibana
- 📌 In production: configure auto-block rule in Suricata/firewall for repeated scans from same IP

---

## 8. References

- [Suricata Alert Rules — ET SCAN](https://rules.emergingthreats.net/)
- [MITRE ATT&CK — T1046 Network Service Scanning](https://attack.mitre.org/techniques/T1046/)
- [Nmap Documentation](https://nmap.org/book/man.html)
