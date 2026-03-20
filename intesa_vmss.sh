#!/usr/bin/env bash
set -euxo pipefail
 
# --- Ensure apt works correctly ---
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get clean
 
# Rebuild repository list and ensure main, universe, multiverse are enabled
sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe restricted multiverse"
sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main universe restricted multiverse"
sudo add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-security main universe restricted multiverse"
 
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
# 🔹 ADDITION: Install Python 3.10 + pip
# =========================================================
sudo apt-get install -y python3.10 python3.10-venv python3.10-distutils
 
# Set python3.10 as default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
 
# Install pip if not present
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
 
# Upgrade pip and install required packages
python3.10 -m pip install --upgrade pip==26.0.1 pip-audit==2.10.0
 
# =========================================================
 
# --- Function: Install Terraform ---
function install_terraform() {(
  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y gnupg software-properties-common wget
 
  # Add HashiCorp official repo
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
pip --version
terraform -version
az version
