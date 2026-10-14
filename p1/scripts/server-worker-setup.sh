#!/bin/bash
set -euo pipefail

IFACE=$(ip -o -4 addr show | awk -v ip="192.168.56.111" '$4 ~ "^"ip"/" {print $2}')
apt-get update -qq && apt-get install -y -qq curl net-tools
echo 'export PATH=$PATH:/usr/sbin' >> /home/vagrant/.profile

curl -sfL https://get.k3s.io | \
  K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$K3S_TOKEN" sh -s - agent \
  --node-ip "192.168.56.111" \
  --flannel-iface "$IFACE"