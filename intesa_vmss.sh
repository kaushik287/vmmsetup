#!/usr/bin/env bash
set -euxo pipefail

# --- Non-interactive mode (prevents debconf errors) ---
export DEBIAN_FRONTEND=noninteractive

# --- Clean apt safely ---
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# --- Update package lists ---
sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5

# --- Install base packages ---
sudo apt-get install -y \
  unzip \
  zip \
  gnupg \
  gpg \
  curl \
  wget \
  lsb-release \
  software-properties-common \
  jq

# =========================================================
# 🔹 Install Python (Ubuntu 22.04 & 24.04 compatible)
# =========================================================
sudo apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  python3-setuptools

# Make python -> python3 (optional but useful)
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Upgrade pip safely
python3 -m pip install --upgrade pip

# Install required Python tools
python3 -m pip install pip-audit==2.10.0

# =========================================================

# --- Function: Install Terraform ---
install_terraform() {
  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y gnupg software-properties-common wget

  # Add HashiCorp GPG key
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

  # Add HashiCorp repo
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y terraform unzip zip
}

# --- Function: Install Azure CLI ---
install_azcli() {
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

# --- Execute installations ---
install_azcli
install_terraform

# --- Verify installations ---
echo "===== Versions ====="
python --version
python3 -m pip --version
terraform -version
az version

echo "===== Setup Completed Successfully ====="
