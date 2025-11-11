#!/bin/bash
# ===================================================================
# Script: install_terraform_for_jenkins.sh
# Purpose: Install Terraform (latest stable), configure Jenkins user,
#          and set permissions on Ubuntu/Linux EC2.
# Author: Vijay Setup Script
# ===================================================================

# Step 1: Update system
echo "[INFO] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Step 2: Install required dependencies
echo "[INFO] Installing required packages..."
sudo apt install -y wget unzip curl apt-transport-https gnupg lsb-release

# Step 3: Download latest Terraform (v1.9.8)
TERRAFORM_VERSION="1.9.8"
echo "[INFO] Downloading Terraform v${TERRAFORM_VERSION}..."
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O terraform.zip

# Step 4: Unzip and move binary
echo "[INFO] Installing Terraform..."
unzip terraform.zip
sudo mv terraform /usr/local/bin/
sudo chmod 755 /usr/local/bin/terraform

# Step 5: Verify installation
echo "[INFO] Verifying Terraform installation..."
terraform -version

# Step 6: Create Jenkins user (if not exists)
if id "jenkins" &>/dev/null; then
    echo "[INFO] Jenkins user already exists."
else
    echo "[INFO] Creating Jenkins user..."
    sudo useradd -m -s /bin/bash jenkins
    echo "Jenkins user created successfully."
fi

# Step 7: Give Jenkins permissions for Terraform and workspace
echo "[INFO] Setting permissions for Jenkins..."
sudo chown -R jenkins:jenkins /usr/local/bin/terraform
sudo chmod 755 /usr/local/bin/terraform

# Ensure Jenkins workspace directory exists
sudo mkdir -p /var/lib/jenkins/workspace
sudo chown -R jenkins:jenkins /var/lib/jenkins

# Step 8: Add Terraform to Jenkins PATH
echo "[INFO] Adding Terraform to Jenkins PATH..."
sudo su - jenkins -c "echo 'export PATH=\$PATH:/usr/local/bin' >> ~/.bashrc"
sudo su - jenkins -c "source ~/.bashrc"

# Step 9: Verify as Jenkins user
echo "[INFO] Verifying Terraform as Jenkins user..."
sudo -u jenkins terraform -version

echo "[SUCCESS] Terraform v${TERRAFORM_VERSION} installation and Jenkins setup complete!"
echo "[INFO] Ready to run Terraform pipelines via Jenkins."

