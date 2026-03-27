#!/bin/bash
# ============================================================
# SOC Lab — Phase 2: Install Suricata (Network IDS/IPS)
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
echo "  🔍 SOC Lab — Phase 2: Install Suricata"
echo "============================================="
echo ""

# ── Read interface from Phase 1 ───────────────────────────
if [ -f /etc/soc-lab-interface ]; then
  INTERFACE=$(cat /etc/soc-lab-interface)
  ok "Using interface: $INTERFACE"
else
  INTERFACE=$(ip link show | awk '/^[0-9]+: /{print $2}' | tr -d ':' | grep -v lo | head -1)
  info "Auto-detected interface: $INTERFACE"
fi

# ── Step 1: Install Suricata ──────────────────────────────
info "Installing Suricata..."
sudo apt install -y suricata
ok "Suricata installed: $(suricata --version 2>&1 | head -1)"

# ── Step 2: Update rules ──────────────────────────────────
info "Downloading latest threat detection rules..."
sudo suricata-update
ok "Rules updated"

# ── Step 3: Configure Suricata ────────────────────────────
info "Configuring Suricata..."
SURICATA_CONF="/etc/suricata/suricata.yaml"

# Backup original config
sudo cp $SURICATA_CONF ${SURICATA_CONF}.bak
ok "Original config backed up"

# Set HOME_NET
sudo sed -i 's/HOME_NET: .*/HOME_NET: "[192.168.0.0\/16,10.0.0.0\/8,172.16.0.0\/12]"/' $SURICATA_CONF
ok "HOME_NET set"

# Set interface
sudo sed -i "/af-packet:/,/interface:/{s/interface: .*/interface: $INTERFACE/}" $SURICATA_CONF
ok "Interface set to $INTERFACE"

# ── Step 4: Start Suricata ────────────────────────────────
info "Starting Suricata daemon..."
sudo suricata -c $SURICATA_CONF -i $INTERFACE -D
sleep 2

# ── Step 5: Verify ────────────────────────────────────────
if pgrep -x suricata > /dev/null; then
  ok "Suricata is running!"
else
  fail "Suricata failed to start. Check: sudo journalctl -u suricata -n 50"
fi

echo ""
echo "─────────────────────────────────────────────"
echo "  📋 Suricata Quick Reference"
echo "─────────────────────────────────────────────"
echo "  Live alerts:  sudo tail -f /var/log/suricata/fast.log"
echo "  Full events:  sudo tail -f /var/log/suricata/eve.json"
echo "  Restart:      sudo systemctl restart suricata"
echo "  Config:       /etc/suricata/suricata.yaml"
echo "─────────────────────────────────────────────"
echo ""
ok "Phase 2 complete! Proceed to Phase 3: install_wazuh.sh"
