#!/bin/bash
set -euo pipefail

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

LOGFILE=/root/logs/qdrant
mkdir -p mkdir -p "$LOGFILE"

echo -e "\nStarting Qdrant with bootstrap to primary node ${QDRANT_PRIMARY_NODE} and local uri ${VPNHOST}:6335..."

pkill qdrant

./qdrant --config-path ./config/config.yaml  \
         --bootstrap http://$QDRANTHOME:6335  \
         --uri http://$VPNHOST:16335   \
         2>&1 | multilog t s5000000 n3 "$LOGFILE" &
