#!/bin/bash

# Install prereqs:
apt-get update
apt-get install -y gpg wget

# Install vault
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt-get update 
apt-get install -y vault

## Security Hardening
# Disable core dumps
echo '* hard core 0' >> /etc/security/limits.config
echo 'fs.suid_dumpable = 0' >> /etc/sysctl.conf
sysctl -p
echo 'ulimit -S -c 0 > /dev/null 2>&1' >> /etc/profile


# Create storage backend
mkdir -p /vault/data
chown -R vault:vault /vault/data

# Set vault config
cp /vagrant/vault_config.hcl /etc/vault.d/vault.hcl
chown -R vault:vault /etc/vault.d
chmod 644 /etc/vault.d/vault.hcl
