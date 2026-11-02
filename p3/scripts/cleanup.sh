#!/bin/bash
set -euo pipefail

CLUSTER="iot"
PID_FILE="/tmp/iot-argocd-port-forward.pid"

if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
fi
pkill -f "kubectl port-forward svc/argocd-server" 2>/dev/null || true

if k3d cluster list | grep -qw "$CLUSTER"; then
    k3d cluster delete "$CLUSTER"
else
    echo "all good. cluster '$CLUSTER' does not exist"
fi

if [ "${1:-}" = "--images" ]; then
    echo "removing unused docker images ..."
    docker image prune -a -f
fi