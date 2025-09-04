#!/usr/bin/env bash
set -euxo pipefail

# -----------------------------
# Fix apt repos and mirrors
# -----------------------------

# Enable universe & multiverse repos (needed for unzip, jq, etc.)
sudo add-apt-repository universe -y || true
sudo add-apt-repository multiverse -y || true

# Use Azure mirror for stability (faster and avoids mirror sync issues)
sudo sed -i 's|http://archive.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list
sudo sed -i 's|http://security.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

# Reset and update apt cache
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y

# -----------------------------
# Install common tools
# -----------------------------
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  unzip \
  zip \
  gnupg \
  gpg \
  curl \
  wget \
  lsb-release \
  software-properties-common \
  jq

# -----------------------------
# Install Terraform
# -----------------------------
function install_terraform() {(
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y terraform
)}

# -----------------------------
# Install Azure CLI
# -----------------------------
function install_azcli() {(
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
)}

# -----------------------------
# Execute installers
# -----------------------------
install_azcli
install_terraform

# Add Azure DevOps CLI extension
az extension add --name azure-devops
