#!/bin/bash

# Qdrant launcher script for vast servers
# All configurations are loaded from .env file in the same directory as this script or in /root/.env

#set -euo pipefail

#Kill any existing qdrant process
pkill qdrant || true

# Load environment variables if .env exists
if [ -f "/root/.env" ]; then
    set -a
    source "/root/.env"
    set +a
elif [ -f "$(dirname "$0")/.env" ]; then
    set -a
    source "$(dirname "$0")/.env"
    set +a
fi

# Add Qdrant primary node to /etc/hosts if not present
grep -q "${QDRANT_PRIMARY_NODE}" /etc/hosts || echo "127.0.0.1 ${QDRANT_PRIMARY_NODE}" | sudo tee -a /etc/hosts > /dev/null


LOGFILE=/root/logs/qdrant
mkdir -p "$LOGFILE"

echo -e "\nStarting Qdrant with bootstrap to primary node ${QDRANT_PRIMARY_NODE} and local uri ${VPNHOST}:6335..."

pkill qdrant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -rp "$SCRIPT_DIR"/config/config.yaml /qdrant/config/config.yaml
cd /qdrant
./qdrant --config-path ./config/config.yaml  \
         --bootstrap http://$QDRANT_PRIMARY_NODE:6335  \
         --uri http://$VPNHOST:16335   \
         2>&1 | multilog t s5000000 n3 "$LOGFILE" &
         
