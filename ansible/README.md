# Ansible Automation

Automated infrastructure provisioning, configuration management, and deployment for the microservices platform.

## Overview

This Ansible setup provides:
- Infrastructure provisioning and configuration
- Secure secrets management with Ansible Vault
- SSH key deployment
- Service deployment automation
- Database backup automation
- Health monitoring

## Quick Start

### Prerequisites

```bash
# Install Ansible
pip install ansible

# Or via package manager
brew install ansible  # macOS
apt install ansible   # Ubuntu/Debian
```

### Initial Setup

```bash
cd ansible

# Create vault password file
echo "your-secure-vault-password" > .vault_pass
chmod 600 .vault_pass

# Create encrypted secrets file
ansible-vault create vault/secrets.yml
```

### Encrypt Secrets

```bash
# Create encrypted secrets
ansible-vault create vault/secrets.yml

# Edit encrypted secrets
ansible-vault edit vault/secrets.yml

# View encrypted secrets
ansible-vault view vault/secrets.yml

# Rekey (change password)
ansible-vault rekey vault/secrets.yml
```

## Playbooks

### Setup Infrastructure

Prepares target hosts with Docker, users, and directories:

```bash
ansible-playbook playbooks/setup-infrastructure.yml
```

### Deploy SSH Keys and Secrets

Securely deploys SSH keys and credentials:

```bash
ansible-playbook playbooks/manage-secrets.yml
```

### Deploy Services

Deploys microservices to target hosts:

```bash
ansible-playbook playbooks/deploy-services.yml

# Deploy to specific environment
ansible-playbook playbooks/deploy-services.yml -e "environment=production"

# Deploy specific version
ansible-playbook playbooks/deploy-services.yml -e "git_branch=v1.2.3"
```

### Backup Databases

Automated database backups with encryption:

```bash
ansible-playbook playbooks/backup-databases.yml
```

### Health Check

Monitor service health across all hosts:

```bash
ansible-playbook playbooks/health-check.yml
```

## Inventory Management

### Hosts

Edit `inventory/hosts.yml` to define your infrastructure:

```yaml
production:
  children:
    app_servers:
      hosts:
        app-server-01:
          ansible_host: 192.168.1.10
```

### Variables

- `group_vars/all.yml` - Global variables
- `group_vars/production.yml` - Production-specific
- `group_vars/staging.yml` - Staging-specific
- `host_vars/` - Host-specific overrides

## Secrets Management

### Vault Structure

```yaml
# vault/secrets.yml
vault_postgres_password: secure_password
vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

### SSH Key Management

```bash
# Generate deployment key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/deploy_rsa -C "deployment@example.com"

# Add to vault
ansible-vault edit vault/secrets.yml
```

### Best Practices

1. Never commit unencrypted secrets
2. Use separate vault files per environment
3. Rotate vault passwords regularly
4. Use strong encryption keys
5. Keep `.vault_pass` in `.gitignore`

## Common Tasks

### Deploy to Production

```bash
ansible-playbook playbooks/deploy-services.yml \
  -i inventory/hosts.yml \
  -l production \
  --ask-vault-pass
```

### Deploy to Localhost

```bash
ansible-playbook playbooks/deploy-services.yml \
  -i inventory/hosts.yml \
  -l localhost \
  --connection=local
```

### Check Syntax

```bash
ansible-playbook playbooks/deploy-services.yml --syntax-check
```

### Dry Run

```bash
ansible-playbook playbooks/deploy-services.yml --check --diff
```

### Run Specific Tasks

```bash
ansible-playbook playbooks/deploy-services.yml --tags "docker,deploy"
```

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── hosts.yml              # Infrastructure inventory
├── group_vars/
│   ├── all.yml                # Global variables
│   ├── production.yml         # Production vars
│   └── staging.yml            # Staging vars
├── host_vars/                 # Host-specific variables
├── vault/
│   └── secrets.yml.example    # Vault template
├── playbooks/
│   ├── setup-infrastructure.yml
│   ├── deploy-services.yml
│   ├── manage-secrets.yml
│   ├── backup-databases.yml
│   └── health-check.yml
├── templates/
│   ├── env.j2                 # Environment template
│   └── db-credentials.j2      # Credentials template
└── README.md
```

## Environment Variables

Variables can be overridden at runtime:

```bash
ansible-playbook playbooks/deploy-services.yml \
  -e "environment=production" \
  -e "git_branch=main" \
  -e "postgres_max_connections=200"
```

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
ansible all -m ping

# Use specific user
ansible all -m ping -u deploy

# Use specific SSH key
ansible all -m ping --private-key ~/.ssh/deploy_rsa
```

### Vault Issues

```bash
# If you forgot vault password
ansible-vault rekey vault/secrets.yml

# Decrypt file temporarily
ansible-vault decrypt vault/secrets.yml
# ... make changes ...
ansible-vault encrypt vault/secrets.yml
```

### Debug Mode

```bash
ansible-playbook playbooks/deploy-services.yml -vvv
```

## Security Considerations

- All secrets encrypted with Ansible Vault
- SSH keys managed securely
- File permissions enforced (600 for sensitive files)
- Database backups encrypted
- No credentials in version control
- Vault password in `.gitignore`

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run Ansible deployment
  env:
    ANSIBLE_VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD }}
  run: |
    echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass
    ansible-playbook playbooks/deploy-services.yml
```

## Advanced Usage

### Dynamic Inventory

For cloud providers (AWS, GCP, Azure):

```bash
# Install cloud plugins
pip install boto3  # AWS
pip install google-auth  # GCP

# Use dynamic inventory
ansible-playbook playbooks/deploy-services.yml -i aws_ec2.yml
```

### Ansible Roles

Create reusable roles:

```bash
ansible-galaxy init roles/microservices
```

### Callbacks and Logging

Configure in `ansible.cfg`:
- stdout_callback: yaml, json, minimal
- log_path: /var/log/ansible.log

