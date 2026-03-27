#!/bin/bash
# ============================================================
# SOC Lab — Phase 6: Simulate Attacks & Generate Alerts
# Author: Perikala Anusha
# ⚠️  Run ONLY on your own lab machine — never on production!
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

ok()      { echo -e "${GREEN}[✓]${NC} $1"; }
info()    { echo -e "${YELLOW}[→]${NC} $1"; }
attack()  { echo -e "${CYAN}[💥]${NC} $1"; }
section() {
  echo ""
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

echo ""
echo "============================================="
echo "  💥 SOC Lab — Phase 6: Attack Simulation"
echo "  ⚠️  Localhost only — educational use only"
echo "============================================="
echo ""

# ── Verify Suricata is running ────────────────────────────
if ! pgrep -x suricata > /dev/null; then
  echo -e "${RED}[✗]${NC} Suricata is not running! Run Phase 2 first."
  exit 1
fi
ok "Suricata is running — alerts will be captured"

# ── Open log watchers instruction ─────────────────────────
echo ""
echo "  📋 BEFORE RUNNING ATTACKS — Open these in separate terminals:"
echo ""
echo "  Terminal 1:  sudo tail -f /var/log/suricata/fast.log"
echo "  Terminal 2:  sudo tail -f /var/log/auth.log"
echo "  Terminal 3:  (this script)"
echo ""
read -p "  Press ENTER when you're ready to start attacks..."

# ══════════════════════════════════════════════════════════
section "Scenario 1 — Port Scan (Nmap SYN Scan)"
# ══════════════════════════════════════════════════════════
echo ""
echo "  Attack:   Nmap stealth SYN scan on localhost"
echo "  Detect:   Suricata → ET SCAN Nmap Scripting Engine"
echo "  Severity: Medium"
echo ""
attack "Launching port scan against 127.0.0.1..."
sudo nmap -sS -p 1-1000 127.0.0.1 2>&1 | tail -5
ok "Port scan complete — check Suricata fast.log for alerts"

sleep 3

# ══════════════════════════════════════════════════════════
section "Scenario 2 — Ping Flood (ICMP Flood)"
# ══════════════════════════════════════════════════════════
echo ""
echo "  Attack:   ICMP ping flood (50 packets)"
echo "  Detect:   Suricata → ICMP flood / excessive ping"
echo "  Severity: Low"
echo ""
attack "Sending 50 ICMP packets to 127.0.0.1..."
ping -c 50 -i 0.1 127.0.0.1 > /dev/null 2>&1
ok "Ping flood complete"

sleep 3

# ══════════════════════════════════════════════════════════
section "Scenario 3 — SSH Brute Force Simulation"
# ══════════════════════════════════════════════════════════
echo ""
echo "  Attack:   Repeated failed SSH login attempts"
echo "  Detect:   /var/log/auth.log → Failed password entries"
echo "            Wazuh → Authentication failure alert"
echo "  Severity: High"
echo ""
attack "Simulating 5 failed SSH login attempts..."
for i in {1..5}; do
  echo -n "  Attempt $i: "
  ssh -o ConnectTimeout=2 \
      -o StrictHostKeyChecking=no \
      -o BatchMode=yes \
      fakeuser@localhost 2>&1 | grep -oE "(Permission denied|Connection refused|ssh:.*)" | head -1 || echo "Connection failed (expected)"
  sleep 1
done
ok "SSH brute force simulation complete"
ok "Check: sudo grep 'Failed password' /var/log/auth.log | tail -10"

sleep 3

# ══════════════════════════════════════════════════════════
section "Scenario 4 — Directory Traversal (Web Scan)"
# ══════════════════════════════════════════════════════════
echo ""
echo "  Attack:   Curl requests simulating path traversal"
echo "  Detect:   Suricata HTTP anomaly rules"
echo "  Severity: Medium"
echo ""
attack "Sending suspicious HTTP requests..."
# Only if curl is available and local web server exists
for path in "/../../../etc/passwd" "/?id=1;ls" "/admin" "/.env"; do
  curl -s -o /dev/null -w "  GET $path → HTTP %{http_code}\n" \
    "http://localhost$path" 2>/dev/null || echo "  GET $path → No web server (normal in lab)"
done
ok "Web scan simulation complete"

# ══════════════════════════════════════════════════════════
section "📊 Summary — Check Your Alerts"
# ══════════════════════════════════════════════════════════
echo ""
echo "  Run these commands to review what was detected:"
echo ""
echo "  🔎 Suricata Alerts:"
echo "     sudo cat /var/log/suricata/fast.log | tail -20"
echo ""
echo "  🔎 Auth Log (SSH brute force):"
echo "     sudo grep 'Failed\|Invalid' /var/log/auth.log | tail -10"
echo ""
echo "  🔎 Kibana Dashboard:"
echo "     http://localhost:5601 → Discover → suricata*"
echo ""
echo "  📝 Now write your incident reports!"
echo "     Template: ~/soc-lab/reports/incident_001_port_scan.md"
echo ""
ok "Phase 6 complete — Your SOC Lab detected real attacks! 🛡️"
