# Ansible Quick Start Guide

## What You Get

The Ansible automation provides:

✅ **Infrastructure provisioning** - Install Docker, dependencies, users  
✅ **Secrets management** - Encrypted passwords, SSH keys, API tokens with Ansible Vault  
✅ **SSH key deployment** - Automated key distribution to servers  
✅ **Service deployment** - Deploy microservices to production/staging  
✅ **Database backups** - Automated, encrypted backups with retention  
✅ **Health monitoring** - Check service status across all hosts  

## Initial Setup (5 minutes)

```bash
cd ansible

# Run automated setup
./setup-ansible.sh
```

This will:
1. Install Ansible and dependencies
2. Create vault password file
3. Generate SSH deployment keys
4. Install required Ansible collections

## Configure Secrets

```bash
# Edit encrypted secrets (will prompt for vault password)
ansible-vault edit vault/secrets.yml
```

Add your secrets:
```yaml
---
vault_postgres_password: "YourSecurePassword123"
vault_oauth_client_secret: "oauth-secret-xyz"
vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  (paste your SSH private key here)
  -----END OPENSSH PRIVATE KEY-----
```

## Update Inventory

Edit `inventory/hosts.yml` with your server IPs:

```yaml
production:
  children:
    app_servers:
      hosts:
        prod-server-01:
          ansible_host: YOUR_SERVER_IP
          ansible_user: ubuntu
```

## Deploy to Production

```bash
# 1. Setup infrastructure (one-time)
ansible-playbook playbooks/setup-infrastructure.yml

# 2. Deploy SSH keys
ansible-playbook playbooks/manage-secrets.yml

# 3. Deploy services
ansible-playbook playbooks/deploy-services.yml -e "environment=production"

# 4. Check health
ansible-playbook playbooks/health-check.yml
```

## Common Commands

```bash
# Test connectivity
ansible all -m ping

# Deploy to specific host
ansible-playbook playbooks/deploy-services.yml -l prod-server-01

# Backup databases
ansible-playbook playbooks/backup-databases.yml

# View encrypted secrets
ansible-vault view vault/secrets.yml

# Deploy specific version
ansible-playbook playbooks/deploy-services.yml -e "git_branch=v1.0.0"
```

## Security Features

🔐 **AES-256 encryption** for all secrets  
�� **SSH key automation** with proper permissions (600)  
🔒 **Encrypted database backups**  
🚫 **No credentials in code** - everything in Ansible Vault  
✅ **Audit trail** - all changes logged  

## Troubleshooting

**Can't connect to hosts:**
```bash
ansible all -m ping -vvv
```

**Forgot vault password:**
```bash
ansible-vault rekey vault/secrets.yml
```

**Check what would change (dry run):**
```bash
ansible-playbook playbooks/deploy-services.yml --check --diff
```

## Next Steps

1. Read [ansible/README.md](ansible/README.md) for detailed documentation
2. Read [docs/ANSIBLE_GUIDE.md](docs/ANSIBLE_GUIDE.md) for advanced usage
3. Customize playbooks for your infrastructure
4. Set up CI/CD integration

## Example Workflow

```bash
# Development
docker-compose up -d

# Staging deployment
cd ansible
ansible-playbook playbooks/deploy-services.yml -l staging

# Production deployment
ansible-playbook playbooks/deploy-services.yml -l production -e "git_branch=v1.2.3"

# Automated daily backups (cron)
0 2 * * * cd /opt/microservices/ansible && ansible-playbook playbooks/backup-databases.yml
```
