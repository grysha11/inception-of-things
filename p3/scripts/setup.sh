#!/bin/bash
set -euo pipefail

CLUSTER="iot"
ARGOCD_MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if k3d cluster list | grep -qw "$CLUSTER"; then
    echo "all good cluster '$CLUSTER' already exists"
else
    k3d cluster create "$CLUSTER" -p "8888:8888@loadbalancer"
fi

echo "wait for node to be ready ..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

for ns in argocd dev; do
    kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -n argocd --server-side --force-conflicts -f "$ARGOCD_MANIFEST"
echo "wait for argocd to be ready..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s

kubectl apply -f "$SCRIPT_DIR/../confs/application.yaml"
echo "wait for the app to be synced and healthy..."
kubectl wait -n argocd application/iot-app \
    --for=jsonpath='{.status.health.status}'=Healthy --timeout=300s \
    || echo "warning: app not healthy yet, check: kubectl get applications -n argocd"

PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd \
            -o jsonpath='{.data.password}' | base64 -d)

echo "login     : admin / $PASSWORD"
echo "app       : http://localhost:8888"