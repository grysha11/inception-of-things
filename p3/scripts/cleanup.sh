#!/bin/bash
set -euo pipefail

CLUSTER="iot"

if k3d cluster list | grep -qw "$CLUSTER"; then
    k3d cluster delete "$CLUSTER"
else
    echo "all good. cluster '$CLUSTER' does not exist"
fi

if [ "${1:-}" = "--images" ]; then
    echo "removing unused docker images ..."
    docker image prune -a -f
fi