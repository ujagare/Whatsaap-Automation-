#!/bin/bash
# ============================================================
# OpenWA - Oracle Cloud VM setup script
# Ubuntu 22.04+ (ARM Ampere A1 recommended)
# Run: bash oracle-setup.sh
# ============================================================
set -e

echo "=============================================="
echo " Step 1/5: Installing Docker"
echo "=============================================="
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose-v2

echo "=============================================="
echo " Step 2/5: Cloning OpenWA (v0.23.2)"
echo "=============================================="
cd ~
if [ ! -d "whatsaap" ]; then
  git clone https://github.com/ujagare/Whatsaap-Automation-.git whatsaap
else
  cd whatsaap && git pull
fi
cd ~/whatsaap

echo "=============================================="
echo " Step 3/5: Building Docker image (10-20 min)"
echo "=============================================="
sudo docker build -t openwa:local .

echo "=============================================="
echo " Step 4/5: Starting container (persistent data)"
echo "=============================================="
# Persistent data folder (sessions + database + API key)
sudo mkdir -p ~/openwa-data

# Random master key so production boot is happy
MASTER_KEY=$(openssl rand -hex 24)

sudo docker rm -f openwa 2>/dev/null || true
sudo docker run -d \
  --name openwa \
  --restart=always \
  -p 2785:2785 \
  -v ~/openwa-data:/app/data \
  -e NODE_ENV=production \
  -e API_MASTER_KEY="$MASTER_KEY" \
  -e ENGINE_TYPE=whatsapp-web.js \
  -e DATABASE_TYPE=sqlite \
  -e DATABASE_NAME=./data/openwa.sqlite \
  -e DATABASE_SYNCHRONIZE=true \
  -e PUPPETEER_HEADLESS=true \
  openwa:local

echo "=============================================="
echo " Step 5/5: Verifying + firewall"
echo "=============================================="
sudo ufw allow 22/tcp 2>/dev/null || true
sudo ufw allow 2785/tcp 2>/dev/null || true
sudo ufw --force enable 2>/dev/null || true

sleep 10
sudo docker ps | grep openwa

echo ""
echo "=============================================="
echo " DONE!"
echo "=============================================="
echo " OpenWA URL : http://<VM_IP>:2785"
echo " Swagger    : http://<VM_IP>:2785/api/docs"
echo ""
echo " IMPORTANT - after first boot, get your API key:"
echo "   sudo cat ~/openwa-data/.api-key"
echo ""
echo " Then pair WhatsApp (on your PC, not the VM):"
echo "   pwsh oracle-qr-pair.ps1 -VM_IP <VM_IP>"
echo "=============================================="
