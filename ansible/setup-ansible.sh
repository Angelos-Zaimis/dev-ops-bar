#!/bin/bash

set -e

echo "========================================="
echo "  Ansible Setup for Microservices"
echo "========================================="
echo ""

if ! command -v ansible &> /dev/null; then
    echo "Ansible not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ansible
    elif [[ -f /etc/debian_version ]]; then
        sudo apt update
        sudo apt install -y ansible
    else
        pip3 install ansible
    fi
else
    echo "✓ Ansible is already installed ($(ansible --version | head -1))"
fi

echo ""
echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo ""
echo "Setting up vault password file..."
if [ ! -f .vault_pass ]; then
    read -sp "Enter vault password: " vault_password
    echo ""
    echo "$vault_password" > .vault_pass
    chmod 600 .vault_pass
    echo "✓ Vault password file created"
else
    echo "✓ Vault password file already exists"
fi

echo ""
echo "Creating vault secrets file..."
if [ ! -f vault/secrets.yml ]; then
    cp vault/secrets.yml.example vault/secrets.yml
    echo "✓ Created vault/secrets.yml from template"
    echo ""
    echo "⚠️  IMPORTANT: Edit vault/secrets.yml with your actual secrets:"
    echo "   ansible-vault edit vault/secrets.yml"
else
    echo "✓ Vault secrets file already exists"
fi

echo ""
echo "Generating SSH deployment key..."
if [ ! -f ~/.ssh/deploy_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/deploy_rsa -C "deploy@microservices" -N ""
    echo "✓ SSH key generated at ~/.ssh/deploy_rsa"
    echo ""
    echo "Public key:"
    cat ~/.ssh/deploy_rsa.pub
    echo ""
    echo "⚠️  Add this public key to your target servers' authorized_keys"
else
    echo "✓ SSH deployment key already exists"
fi

echo ""
echo "Testing Ansible configuration..."
ansible --version

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Edit vault/secrets.yml with your secrets:"
echo "     ansible-vault edit vault/secrets.yml"
echo ""
echo "  2. Update inventory/hosts.yml with your servers"
echo ""
echo "  3. Test connectivity:"
echo "     ansible all -m ping"
echo ""
echo "  4. Run playbooks:"
echo "     ansible-playbook playbooks/setup-infrastructure.yml"
echo "     ansible-playbook playbooks/deploy-services.yml"
echo ""

