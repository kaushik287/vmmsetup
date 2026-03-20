#!/usr/bin/env bash
set -euxo pipefail

# --- Non-interactive to avoid debconf issues ---
export DEBIAN_FRONTEND=noninteractive

# --- Clean apt safely ---
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# --- Update repos (no need to re-add default repos unless broken) ---
sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5

# --- Install common packages ---
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
# 🔹 Install Python (Ubuntu 22.04/24.04 compatible)
# =========================================================
sudo apt-get install -y python3 python3-venv python3-distutils python3-pip

# Make python -> python3
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Upgrade pip and install required packages
python3 -m pip install --upgrade pip
python3 -m pip install pip-audit==2.10.0

# =========================================================

# --- Function: Install Terraform ---
function install_terraform() {(
  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y gnupg software-properties-common wget

  # Add HashiCorp repo
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y terraform unzip zip
)}

# --- Function: Install Azure CLI ---
function install_azcli() {(
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
)}

# --- Run installers ---
install_azcli
install_terraform

# --- Verify installations ---
python --version
pip3 --version
terraform -version
az version
