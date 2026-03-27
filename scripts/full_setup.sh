#!/bin/bash
# ============================================================
# SOC Lab — Full Setup (All Phases in One Script)
# Author: Perikala Anusha
# Usage: sudo ./full_setup.sh
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()      { echo -e "${GREEN}[✓]${NC} $1"; }
info()    { echo -e "${YELLOW}[→]${NC} $1"; }
section() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║  $1${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
}

clear
echo ""
echo -e "${CYAN}"
cat << 'BANNER'
  ███████╗ ██████╗  ██████╗      ██╗      █████╗ ██████╗ 
  ██╔════╝██╔═══██╗██╔════╝      ██║     ██╔══██╗██╔══██╗
  ███████╗██║   ██║██║           ██║     ███████║██████╔╝
  ╚════██║██║   ██║██║           ██║     ██╔══██║██╔══██╗
  ███████║╚██████╔╝╚██████╗      ███████╗██║  ██║██████╔╝
  ╚══════╝ ╚═════╝  ╚═════╝      ╚══════╝╚═╝  ╚═╝╚═════╝ 
BANNER
echo -e "${NC}"
echo "          Home Security Operations Center"
echo "          Author: Perikala Anusha"
echo ""
echo "  This script will install:"
echo "    ✦ Suricata  (Network IDS/IPS)"
echo "    ✦ Wazuh     (SIEM Agent)"
echo "    ✦ Elasticsearch + Kibana (ELK Stack)"
echo "    ✦ Filebeat  (Log Shipper)"
echo ""
read -p "  Press ENTER to begin installation..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

section "Phase 1 — Prepare Environment"
bash "$SCRIPT_DIR/01_prepare_environment.sh"

section "Phase 2 — Install Suricata"
bash "$SCRIPT_DIR/02_install_suricata.sh"

section "Phase 3 — Install Wazuh Agent"
bash "$SCRIPT_DIR/03_install_wazuh.sh"

section "Phase 4 — Install ELK Stack"
bash "$SCRIPT_DIR/04_install_elk.sh"

section "Phase 5 — Install Filebeat"
bash "$SCRIPT_DIR/05_install_filebeat.sh"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🎉 SOC LAB SETUP COMPLETE! 🎉        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  Services running:"
echo "    ✦ Suricata:       $(pgrep -x suricata > /dev/null && echo '🟢 Active' || echo '🔴 Not running')"
echo "    ✦ Wazuh Agent:    $(systemctl is-active wazuh-agent 2>/dev/null || echo 'unknown')"
echo "    ✦ Elasticsearch:  $(curl -s localhost:9200 > /dev/null 2>&1 && echo '🟢 Active' || echo '🔴 Not running')"
echo "    ✦ Kibana:         $(systemctl is-active kibana 2>/dev/null || echo 'starting...')"
echo "    ✦ Filebeat:       $(systemctl is-active filebeat 2>/dev/null || echo 'unknown')"
echo ""
echo "  Next step — simulate attacks:"
echo "    sudo ./scripts/06_simulate_attacks.sh"
echo ""
echo "  Open Kibana:"
echo "    http://localhost:5601"
echo ""
ok "Your SOC Lab is live! 🛡️"
