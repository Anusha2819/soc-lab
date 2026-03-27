#!/bin/bash
# ============================================================
# SOC Lab — Phase 4: Install ELK Stack (Elasticsearch + Kibana)
# Author: Perikala Anusha
# RAM-optimised: Elasticsearch capped at 512MB
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
echo "  📊 SOC Lab — Phase 4: Install ELK Stack"
echo "  Version: $ELK_VERSION"
echo "============================================="
echo ""

# ── Step 1: Install Java ──────────────────────────────────
info "Installing Java (required for Elasticsearch)..."
sudo apt install -y default-jdk
JAVA_VER=$(java -version 2>&1 | head -1)
ok "Java installed: $JAVA_VER"

# ── Step 2: Install Elasticsearch ────────────────────────
info "Downloading Elasticsearch $ELK_VERSION..."
wget -q --show-progress \
  https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELK_VERSION}-amd64.deb

info "Installing Elasticsearch..."
sudo dpkg -i elasticsearch-${ELK_VERSION}-amd64.deb
ok "Elasticsearch installed"

# ── Step 3: Cap RAM usage to 512MB ───────────────────────
info "Setting JVM heap to 512MB (RAM-optimised)..."
JVM_OPTIONS="/etc/elasticsearch/jvm.options"
sudo sed -i 's/^-Xms.*/-Xms512m/' $JVM_OPTIONS
sudo sed -i 's/^-Xmx.*/-Xmx512m/' $JVM_OPTIONS
ok "JVM heap: 512MB"

# ── Step 4: Configure Elasticsearch ──────────────────────
info "Configuring Elasticsearch..."
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<'EOF'

# SOC Lab config
network.host: localhost
http.port: 9200
xpack.security.enabled: false
xpack.security.http.ssl.enabled: false
EOF
ok "Elasticsearch configured (security disabled for lab)"

# ── Step 5: Start Elasticsearch ──────────────────────────
info "Starting Elasticsearch (may take ~30 seconds)..."
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

echo -n "  Waiting for Elasticsearch"
for i in {1..30}; do
  if curl -s http://localhost:9200 > /dev/null 2>&1; then
    echo ""
    ok "Elasticsearch is up!"
    break
  fi
  echo -n "."
  sleep 2
done

# ── Step 6: Install Kibana ────────────────────────────────
info "Downloading Kibana $ELK_VERSION..."
wget -q --show-progress \
  https://artifacts.elastic.co/downloads/kibana/kibana-${ELK_VERSION}-amd64.deb

info "Installing Kibana..."
sudo dpkg -i kibana-${ELK_VERSION}-amd64.deb
ok "Kibana installed"

# ── Step 7: Configure Kibana ──────────────────────────────
info "Configuring Kibana..."
sudo tee /etc/kibana/kibana.yml > /dev/null <<'EOF'
server.port: 5601
server.host: "localhost"
elasticsearch.hosts: ["http://localhost:9200"]
EOF
ok "Kibana configured"

# ── Step 8: Start Kibana ──────────────────────────────────
info "Starting Kibana..."
sudo systemctl enable kibana
sudo systemctl start kibana

echo ""
echo "─────────────────────────────────────────────"
echo "  📋 ELK Stack Quick Reference"
echo "─────────────────────────────────────────────"
echo "  Elasticsearch: curl http://localhost:9200"
echo "  Kibana UI:     http://localhost:5601"
echo "  ES Status:     sudo systemctl status elasticsearch"
echo "  Kibana Status: sudo systemctl status kibana"
echo "  ES Logs:       sudo journalctl -u elasticsearch -f"
echo "─────────────────────────────────────────────"
echo ""

# ── Cleanup downloaded .deb files ────────────────────────
rm -f elasticsearch-${ELK_VERSION}-amd64.deb kibana-${ELK_VERSION}-amd64.deb

ok "Phase 4 complete! Kibana will be ready at http://localhost:5601 in ~1-2 min"
ok "Proceed to Phase 5: install_filebeat.sh"
