#!/bin/bash

# =============================================
# Network Check Utility
# Author: Ihor Kriazhev (IgorUspehov)
# GitHub: https://github.com/IgorUspehov
# Tested on: Linux Mint 21.3
# Compatible: Debian, Ubuntu, Linux Mint
# =============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}"
echo "======================================"
echo "        Network Check Utility"
echo "======================================"
echo -e "${NC}"

# --- 1. Local IP ---
echo -e "${YELLOW}[1/5] Local IP address:${NC}"
ip route get 1 | awk '{print "    " $7; exit}' 2>/dev/null || hostname -I | awk '{print "    " $1}'
echo ""

# --- 2. Public IP ---
echo -e "${YELLOW}[2/5] Public IP address:${NC}"
PUB_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
if [ -n "$PUB_IP" ]; then
    echo -e "    ${GREEN}$PUB_IP${NC}"
else
    echo -e "    ${RED}Could not retrieve public IP${NC}"
fi
echo ""

# --- 3. Ping test ---
echo -e "${YELLOW}[3/5] Ping test:${NC}"
HOSTS=("8.8.8.8" "1.1.1.1" "google.com")
for HOST in "${HOSTS[@]}"; do
    RESULT=$(ping -c 3 -W 2 "$HOST" 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
    if [ -n "$RESULT" ]; then
        echo -e "    ${GREEN}✓ $HOST — ${RESULT} ms avg${NC}"
    else
        echo -e "    ${RED}✗ $HOST — unreachable${NC}"
    fi
done
echo ""

# --- 4. DNS check ---
echo -e "${YELLOW}[4/5] DNS resolution:${NC}"
DNS_HOSTS=("google.com" "github.com" "youtube.com")
for HOST in "${DNS_HOSTS[@]}"; do
    IP=$(dig +short "$HOST" 2>/dev/null | head -1)
    if [ -n "$IP" ]; then
        echo -e "    ${GREEN}✓ $HOST → $IP${NC}"
    else
        echo -e "    ${RED}✗ $HOST — DNS failed${NC}"
    fi
done
echo ""

# --- 5. Speed test (via curl) ---
echo -e "${YELLOW}[5/5] Download speed test:${NC}"
echo -e "    Downloading 10MB test file..."
SPEED=$(curl -s --max-time 15 -w "%{speed_download}" -o /dev/null \
    https://speed.hetzner.de/10MB.bin 2>/dev/null)
if [ -n "$SPEED" ] && [ "$SPEED" != "0" ]; then
    MBPS=$(echo "scale=2; $SPEED / 1048576" | bc)
    echo -e "    ${GREEN}Download speed: ${MBPS} MB/s${NC}"
else
    echo -e "    ${RED}Speed test failed or timed out${NC}"
fi
echo ""

echo -e "${CYAN}======================================"
echo -e "  Network check complete!"
echo -e "======================================${NC}"
