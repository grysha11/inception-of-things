#!/bin/bash
set -euo pipefail

IFACE=$(ip -o -4 addr show | awk -v ip="192.168.56.110" '$4 ~ "^"ip"/" {print $2}')
apt-get update -qq && apt-get install -y -qq curl net-tools
echo 'export PATH=$PATH:/usr/sbin' >> /home/vagrant/.profile

curl -sfL https://get.k3s.io | K3S_TOKEN="$K3S_TOKEN" sh -s - server \
  --node-ip "192.168.56.110" \
  --flannel-iface "$IFACE" \
  --write-kubeconfig-mode 644