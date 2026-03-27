#!/bin/bash
# ============================================================
# SOC Lab — Phase 1: Prepare Environment
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
echo "  🛡️  SOC Lab — Phase 1: Environment Setup"
echo "============================================="
echo ""

# ── Step 1: Update system ─────────────────────────────────
info "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y
ok "System updated"

# ── Step 2: Install base tools ────────────────────────────
info "Installing base tools..."
sudo apt install -y \
  curl wget git net-tools unzip \
  python3 python3-pip jq nmap \
  build-essential software-properties-common
ok "Base tools installed"

# ── Step 3: Detect network interface ──────────────────────
info "Detecting network interface..."
INTERFACE=$(ip link show | awk '/^[0-9]+: /{print $2}' | tr -d ':' | grep -v lo | head -1)

if [ -z "$INTERFACE" ]; then
  fail "Could not detect network interface. Run: ip link show"
fi

ok "Network interface detected: $INTERFACE"

# Save interface name for other scripts
echo "$INTERFACE" | sudo tee /etc/soc-lab-interface > /dev/null
ok "Interface saved to /etc/soc-lab-interface"

# ── Step 4: Show system info ──────────────────────────────
echo ""
echo "─────────────────────────────────────"
echo "  📊 System Info"
echo "─────────────────────────────────────"
echo "  OS:        $(lsb_release -d | cut -f2)"
echo "  Kernel:    $(uname -r)"
echo "  RAM:       $(free -h | awk '/^Mem/{print $2}')"
echo "  Interface: $INTERFACE"
echo "  IP:        $(ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)"
echo "─────────────────────────────────────"
echo ""
ok "Phase 1 complete! Proceed to Phase 2: install_suricata.sh"
