#!/bin/bash
set -euo pipefail

IFACE=$(ip -o -4 addr show | awk -v ip="192.168.56.110" '$4 ~ "^"ip"/" {print $2}')
apt-get update -qq && apt-get install -y -qq curl net-tools
echo 'export PATH=$PATH:/usr/sbin' >> /home/vagrant/.profile

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip "192.168.56.110" \
  --flannel-iface "$IFACE" \
  --write-kubeconfig-mode 644

until kubectl get nodes 2>/dev/null | grep -q " Ready"; do sleep 3; done
kubectl apply -f /tmp/confs/