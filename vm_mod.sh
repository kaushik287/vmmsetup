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
