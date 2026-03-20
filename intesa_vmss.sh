#!/usr/bin/env bash
set -euxo pipefail

# --- Non-interactive mode ---
export DEBIAN_FRONTEND=noninteractive

# --- Clean apt ---
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# --- Update ---
sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5

# --- Base packages ---
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
# 🔹 Python setup (Ubuntu 24.04 safe)
# =========================================================
sudo apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  python3-setuptools

# Set python alias
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# --- Create isolated virtual environment (FIX for PEP 668) ---
sudo mkdir -p /opt/venv
sudo python3 -m venv /opt/venv

# Activate venv
source /opt/venv/bin/activate

# Upgrade pip inside venv
pip install --upgrade pip

# Install required Python tools
pip install pip-audit==2.10.0

# Make pip-audit globally usable (optional)
sudo ln -sf /opt/venv/bin/pip-audit /usr/local/bin/pip-audit

# =========================================================

# --- Install Terraform ---
install_terraform() {
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt-get update --allow-releaseinfo-change -o Acquire::Retries=5
  sudo apt-get install -y terraform
}

# --- Install Azure CLI ---
install_azcli() {
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

# --- Run installations ---
install_azcli
install_terraform

# --- Verify ---
echo "===== Versions ====="
python --version
/opt/venv/bin/pip --version
terraform -version
az version

echo "===== SUCCESS ====="
