#!/bin/bash

# Set a default repo name if not provided
REPO_NAME=${1:-tosin2013/device-edge-demos}

# Ensure Git is installed
sudo dnf install -y git

# Check if the repository is already cloned
if [ -d "$HOME/device-edge-demos" ]; then
  cd $HOME/device-edge-demos
  git config pull.rebase false
  git pull
else
  cd $HOME
  git clone https://github.com/${REPO_NAME}.git
  cd $HOME/device-edge-demos
fi

# Install System Packages
./hack/partial-rpm-packages.sh

# Run the configuration script to setup the bastion host with:
# - Python 3.9
# - Ansible
# - Ansible Navigator
# - Pip modules
./hack/partial-python39-setup.sh
