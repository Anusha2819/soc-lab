#!/bin/bash
# ============================================================
# SOC Lab — Phase 5: Install Filebeat (Log Shipper)
# Author: Perikala Anusha
# Ships: Suricata + Wazuh logs → Elasticsearch
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${YELLOW}[→]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

ELK_VERSION="8.11.0"

echo ""
echo "============================================="
echo "  📦 SOC Lab — Phase 5: Install Filebeat"
echo "============================================="
echo ""

# ── Step 1: Check Elasticsearch is up ────────────────────
info "Checking Elasticsearch connection..."
if ! curl -s http://localhost:9200 > /dev/null; then
  fail "Elasticsearch is not running! Run Phase 4 first."
fi
ok "Elasticsearch is reachable"

# ── Step 2: Download and install Filebeat ─────────────────
info "Downloading Filebeat $ELK_VERSION..."
wget -q --show-progress \
  https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${ELK_VERSION}-amd64.deb

info "Installing Filebeat..."
sudo dpkg -i filebeat-${ELK_VERSION}-amd64.deb
ok "Filebeat installed"

# ── Step 3: Configure Filebeat ────────────────────────────
info "Writing Filebeat config..."
sudo tee /etc/filebeat/filebeat.yml > /dev/null <<'EOF'
# ─────────────────────────────────────────────────────────
# Filebeat Configuration — SOC Lab
# Ships Suricata and Wazuh logs to Elasticsearch
# ─────────────────────────────────────────────────────────

filebeat.inputs:

# Suricata JSON events
- type: log
  enabled: true
  paths:
    - /var/log/suricata/eve.json
  json.keys_under_root: true
  json.add_error_key: true
  tags: ["suricata"]

# Suricata fast alerts
- type: log
  enabled: true
  paths:
    - /var/log/suricata/fast.log
  tags: ["suricata-alerts"]

# Wazuh alerts
- type: log
  enabled: true
  paths:
    - /var/ossec/logs/alerts/alerts.json
  json.keys_under_root: true
  json.add_error_key: true
  tags: ["wazuh"]

# System auth log
- type: log
  enabled: true
  paths:
    - /var/log/auth.log
  tags: ["auth"]

# Syslog
- type: log
  enabled: true
  paths:
    - /var/log/syslog
  tags: ["syslog"]

# ─────────────────────────────────────
output.elasticsearch:
  hosts: ["localhost:9200"]
  protocol: "http"

setup.kibana:
  host: "localhost:5601"

# Logging
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
EOF
ok "Filebeat config written"

# ── Step 4: Enable Suricata module ────────────────────────
info "Enabling Suricata module..."
sudo filebeat modules enable suricata
ok "Suricata module enabled"

# ── Step 5: Setup Kibana dashboards ──────────────────────
info "Setting up Kibana dashboards (may take a minute)..."
sudo filebeat setup --dashboards 2>&1 | tail -3
ok "Kibana dashboards configured"

# ── Step 6: Start Filebeat ────────────────────────────────
info "Starting Filebeat..."
sudo systemctl enable filebeat
sudo systemctl start filebeat
sleep 2

STATUS=$(sudo systemctl is-active filebeat)
if [ "$STATUS" = "active" ]; then
  ok "Filebeat is running and shipping logs!"
else
  fail "Filebeat failed. Check: sudo journalctl -u filebeat -f"
fi

# ── Cleanup ───────────────────────────────────────────────
rm -f filebeat-${ELK_VERSION}-amd64.deb

echo ""
echo "─────────────────────────────────────────────"
echo "  📋 Filebeat Quick Reference"
echo "─────────────────────────────────────────────"
echo "  Status:   sudo systemctl status filebeat"
echo "  Logs:     sudo journalctl -u filebeat -f"
echo "  Test:     sudo filebeat test config"
echo "  Kibana:   http://localhost:5601 → Discover → suricata*"
echo "─────────────────────────────────────────────"
echo ""
ok "Phase 5 complete! All logs now shipping to Elasticsearch."
ok "Open Kibana → http://localhost:5601 and proceed to Phase 6!"
