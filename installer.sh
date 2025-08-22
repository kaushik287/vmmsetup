#!/usr/bin/env bash

set -euxo pipefail
sudo apt-get update
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
function install_terraform() {(
  sudo apt-get update
  sudo apt-get install -y \
    gnupg \
    software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt-get install -y terraform
  sudo apt-get install -y unzip
  sudo apt-get install -y zip
)}

function install_azcli() {(
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
)}

install_azcli
install_terraform
az extension add --name azure-devops
