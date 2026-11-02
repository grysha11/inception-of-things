#!/bin/bash
set -euo pipefail

if command -v docker >/dev/null 2>&1; then
    echo "all good. docker already installed: $(docker --version)"
else
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin
fi

if id -nG "$USER" | grep -qw docker; then
    echo "all good. $USER is in docker group"
else
    sudo usermod -aG docker "$USER"
    echo "added user to user to docker group. relog to continue"
fi

if command -v kubectl >/dev/null 2>&1; then
    echo "all good. kubectl already installed"
else
    curl -fsSLO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    sudo install -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

if command -v k3d >/dev/null 2>&1; then
    echo "all good. k3d is already installed: $(k3d version | head -1)"
else
    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi