#!/bin/bash
set -euo pipefail

CLUSTER="iot"

if k3d cluster list | grep -qw "$CLUSTER"; then
    echo "all good cluster '$CLUSTER' already exists"
else
    k3d cluster create "$CLUSTER" -p "8888:8888@loadbalancer"
fi

echo "Wait for node to be ready ..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

for ns in argocd dev; do
    kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl get ns