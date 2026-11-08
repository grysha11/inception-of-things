#!/bin/bash
set -euo pipefail

ISO_NAME="debian-13.7.0-arm64-netinst.iso"
BOX_NAME="hzakharc/debian-13"
PACKER_DIR="$(cd "$(dirname "$0")/../confs/packer" && pwd)"

cd "$PACKER_DIR"
mkdir -p iso output

SUMS=""
for url in \
    "https://cdimage.debian.org/debian-cd/13.7.0/arm64/iso-cd/SHA256SUMS" \
    "https://cdimage.debian.org/cdimage/archive/13.7.0/arm64/iso-cd/SHA256SUMS"; do
    if SUMS=$(curl -fsSL "$url"); then break; fi
done
CHECKSUM=$(echo "$SUMS" | awk -v f="$ISO_NAME" '$2 == f {print $1}')
if [ -z "$CHECKSUM" ]; then
    echo "error: could not find the official checksum for $ISO_NAME" >&2
    exit 1
fi
echo "official sha256 for $ISO_NAME: $CHECKSUM"
 
if [ ! -f "iso/$ISO_NAME" ]; then
    echo "note: iso/$ISO_NAME not found, Packer will download it from Debian"
fi
 
packer init .
packer build -force \
    -var "iso_name=$ISO_NAME" \
    -var "iso_checksum=$CHECKSUM" \
    .
 
vagrant box add --force --name "$BOX_NAME" "output/debian-13-arm64.box"
echo "Done. Box '$BOX_NAME' is ready for vagrant up."