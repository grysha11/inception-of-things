#!/bin/bash
set -euo pipefail

PID_FILE="/tmp/iot-argocd-port-forward.pid"
LOG_FILE="/tmp/iot-argocd-port-forward.log"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "all good. port-forward already running (pid $(cat "$PID_FILE"))"
    exit 0
fi

nohup bash -c '
    while true; do
        kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0
        sleep 2
    done
' > "$LOG_FILE" 2>&1 &

echo $! > "$PID_FILE"
echo "port-forward started (pid $!), logs in $LOG_FILE"
echo "  argocd ui : https://localhost:8080 (vm which i will not use)"
echo "              https://192.168.56.10:8080 (host macintoshing)"