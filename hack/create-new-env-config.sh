#!/bin/bash

# on demo.redhat.com INVENTORY can be GUID
read -p "Enter your Inventory Name [default: vmc]: " INVENTORY
INVENTORY=${INVENTORY:-vmc}

# Check for the device-edge-demos directory
if [ ! -d "$HOME/device-edge-demos" ]; then
  echo "ERROR: device-edge-demos directory not found"
  exit 1
fi

cd $HOME/device-edge-demos

mkdir -p inventories/${INVENTORY}/group_vars
mkdir -p inventories/${INVENTORY}/group_vars/sno_clusters

cp demos/rhde-pipeline/playbooks/vars/controller-configuration.yml inventories/${INVENTORY}/group_vars/all.yaml

cat >inventories/${INVENTORY}/group_vars/sno_clusters/path.yml<<EOF
tmpdir:
  path: /tmp
EOF
