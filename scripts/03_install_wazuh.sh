#!/bin/bash
# ============================================================
# SOC Lab — Phase 3: Install Wazuh Agent (SIEM)
# Author: Perikala Anusha
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${YELLOW}[→]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "============================================="
echo "  🔐 SOC Lab — Phase 3: Install Wazuh Agent"
echo "============================================="
echo ""

# ── Step 1: Add Wazuh GPG key and repo ───────────────────
info "Adding Wazuh repository..."
wget -q -O - https://packages.wazuh.com/key/GPG-KEY-WAZUH \
  | sudo gpg --dearmor -o /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] \
https://packages.wazuh.com/4.x/apt/ stable main" \
  | sudo tee /etc/apt/sources.list.d/wazuh.list > /dev/null

sudo apt update -y
ok "Wazuh repo added"

# ── Step 2: Install Wazuh Agent ───────────────────────────
info "Installing Wazuh agent..."
sudo apt install -y wazuh-agent
ok "Wazuh agent installed"

# ── Step 3: Configure Agent ───────────────────────────────
info "Configuring Wazuh agent (manager: 127.0.0.1)..."
OSSEC_CONF="/var/ossec/etc/ossec.conf"

sudo tee $OSSEC_CONF > /dev/null <<'EOF'
<ossec_config>
  <client>
    <server>
      <address>127.0.0.1</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
  </client>

  <logging>
    <log_format>plain</log_format>
  </logging>

  <syscheck>
    <frequency>79200</frequency>
    <directories>/etc,/usr/bin,/usr/sbin</directories>
    <directories>/bin,/sbin</directories>
  </syscheck>

  <rootcheck>
    <frequency>36000</frequency>
  </rootcheck>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>

  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/syslog</location>
  </localfile>

  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
</ossec_config>
EOF

ok "Wazuh agent configured"

# ── Step 4: Start agent ───────────────────────────────────
info "Starting Wazuh agent..."
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
sleep 2

# ── Step 5: Verify ────────────────────────────────────────
STATUS=$(sudo systemctl is-active wazuh-agent)
if [ "$STATUS" = "active" ]; then
  ok "Wazuh agent is running!"
else
  info "Wazuh agent status: $STATUS"
  info "(Note: If no manager is running locally, agent may show 'activating' — this is normal)"
fi

echo ""
echo "─────────────────────────────────────────────"
echo "  📋 Wazuh Quick Reference"
echo "─────────────────────────────────────────────"
echo "  Status:   sudo systemctl status wazuh-agent"
echo "  Logs:     sudo tail -f /var/ossec/logs/ossec.log"
echo "  Alerts:   sudo tail -f /var/ossec/logs/alerts/alerts.log"
echo "  Config:   /var/ossec/etc/ossec.conf"
echo "─────────────────────────────────────────────"
echo ""
ok "Phase 3 complete! Proceed to Phase 4: install_elk.sh"
