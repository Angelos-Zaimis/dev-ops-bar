# Ansible Automation Guide

## Introduction

This project uses Ansible for infrastructure automation, configuration management, and secure deployment of microservices. Ansible provides a declarative approach to managing infrastructure with built-in secrets management via Ansible Vault.

## Why Ansible?

- **Agentless**: No software installation required on managed hosts
- **Idempotent**: Safe to run multiple times
- **Declarative**: Define desired state, not steps
- **Extensible**: Custom modules and plugins
- **Secure**: Built-in secrets encryption

## Architecture

### Directory Structure

```
ansible/
├── ansible.cfg              # Configuration settings
├── requirements.yml         # Dependencies (collections, roles)
├── inventory/              
│   └── hosts.yml           # Server inventory
├── group_vars/             
│   ├── all.yml             # Variables for all hosts
│   ├── production.yml      # Production environment
│   └── staging.yml         # Staging environment
├── vault/
│   └── secrets.yml         # Encrypted secrets (Ansible Vault)
├── playbooks/
│   ├── setup-infrastructure.yml
│   ├── deploy-services.yml
│   ├── manage-secrets.yml
│   ├── backup-databases.yml
│   └── health-check.yml
└── templates/
    ├── env.j2              # Jinja2 templates
    └── db-credentials.j2
```

## Secrets Management with Ansible Vault

### Understanding Ansible Vault

Ansible Vault encrypts sensitive data at rest using AES256 encryption. This allows you to:
- Store passwords, API keys, and certificates in version control
- Share secrets securely across teams
- Automate deployments without exposing credentials

### Setting Up Vault

#### 1. Create Vault Password File

```bash
cd ansible
echo "your-strong-vault-password" > .vault_pass
chmod 600 .vault_pass
```

⚠️ **Never commit `.vault_pass` to version control**

#### 2. Create Encrypted Secrets File

```bash
ansible-vault create vault/secrets.yml
```

This opens your default editor. Add secrets:

```yaml
---
vault_postgres_password: "MySecureDbPass123!"
vault_kafka_password: "KafkaSecretPass456!"
vault_oauth_client_secret: "oauth-secret-789"

vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
  ... (your actual private key) ...
  -----END OPENSSH PRIVATE KEY-----

vault_db_backup_encryption_key: "backup-encryption-key-xyz"
```

#### 3. Edit Encrypted File

```bash
ansible-vault edit vault/secrets.yml
```

#### 4. View Encrypted File

```bash
ansible-vault view vault/secrets.yml
```

#### 5. Change Vault Password

```bash
ansible-vault rekey vault/secrets.yml
```

### SSH Key Management

#### Generate Deployment Keys

```bash
# Generate SSH key pair for deployment
ssh-keygen -t ed25519 -f ~/.ssh/deploy_ed25519 -C "deploy@microservices"

# Or use RSA (traditional)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/deploy_rsa -C "deploy@microservices"
```

#### Add to Vault

```bash
# Edit vault
ansible-vault edit vault/secrets.yml

# Add the private key content
vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  <paste your private key here>
  -----END OPENSSH PRIVATE KEY-----

vault_ssh_public_key: "ssh-ed25519 AAAA... deploy@microservices"
```

#### Deploy Keys to Hosts

```bash
ansible-playbook playbooks/manage-secrets.yml
```

This playbook:
1. Creates `.ssh` directory with correct permissions (700)
2. Deploys private key with permissions (600)
3. Deploys public key
4. Adds public key to `authorized_keys`
5. Sets proper ownership

## Playbook Workflows

### 1. Initial Infrastructure Setup

Prepares fresh servers with Docker and dependencies:

```bash
ansible-playbook playbooks/setup-infrastructure.yml
```

**What it does:**
- Updates package cache
- Installs Docker and dependencies
- Creates deployment user
- Configures Docker permissions
- Creates project directories
- Sets timezone
- Enables Docker service

**First-time setup:**
```bash
# Target specific hosts
ansible-playbook playbooks/setup-infrastructure.yml -l production

# Use sudo password
ansible-playbook playbooks/setup-infrastructure.yml --ask-become-pass

# Use specific SSH key
ansible-playbook playbooks/setup-infrastructure.yml --private-key ~/.ssh/my-key
```

### 2. Deploy SSH Keys and Secrets

```bash
ansible-playbook playbooks/manage-secrets.yml
```

**Security features:**
- Encrypts data in transit (SSH)
- Sets restrictive file permissions
- Uses `no_log: true` to hide sensitive output
- Validates key formats

### 3. Deploy Microservices

```bash
# Basic deployment
ansible-playbook playbooks/deploy-services.yml

# Production deployment
ansible-playbook playbooks/deploy-services.yml \
  -e "environment=production" \
  -e "git_branch=v1.0.0"

# Staging with specific version
ansible-playbook playbooks/deploy-services.yml \
  -l staging \
  -e "git_branch=develop"
```

**Deployment flow:**
1. Clones/updates repository
2. Copies docker-compose files
3. Generates `.env` from template with vault secrets
4. Pulls latest Docker images
5. Stops existing services
6. Starts infrastructure (DBs, Kafka)
7. Waits for readiness
8. Starts application services
9. Verifies health

### 4. Automated Backups

```bash
# Manual backup
ansible-playbook playbooks/backup-databases.yml

# Scheduled via cron (add to crontab)
0 2 * * * cd /opt/microservices && ansible-playbook ansible/playbooks/backup-databases.yml
```

**Backup features:**
- Timestamped backups
- AES-256 encryption
- Automatic cleanup (retention policy)
- Verifies encryption key from vault

**Restore from backup:**

```bash
# Decrypt backup
openssl enc -aes-256-cbc -d -pbkdf2 \
  -in backup_20251008.sql.enc \
  -out backup_20251008.sql \
  -k "your-encryption-key"

# Restore to database
cat backup_20251008.sql | docker exec -i servicedb \
  psql -U testuser datasource_servicedb
```

### 5. Health Monitoring

```bash
# Check all services
ansible-playbook playbooks/health-check.yml

# Check specific environment
ansible-playbook playbooks/health-check.yml -l production

# Output to file
ansible-playbook playbooks/health-check.yml > health-report.txt
```

## Inventory Management

### Host Definition

`inventory/hosts.yml`:

```yaml
production:
  children:
    app_servers:
      hosts:
        prod-app-01:
          ansible_host: 10.0.1.10
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "{{ ssh_private_key_path }}"
        prod-app-02:
          ansible_host: 10.0.1.11
          ansible_user: ubuntu

    db_servers:
      hosts:
        prod-db-01:
          ansible_host: 10.0.2.10
          ansible_user: ubuntu
```

### Variable Precedence

Ansible applies variables in this order (highest precedence first):

1. Extra vars (`-e` flag)
2. Task vars
3. Block vars
4. Role vars
5. Play vars
6. Host vars
7. Group vars
8. Defaults

### Using Variables

```yaml
# group_vars/production.yml
postgres_max_connections: 200
backup_retention_days: 30

# Override at runtime
ansible-playbook deploy.yml -e "postgres_max_connections=300"
```

## Best Practices

### Security

1. **Never commit unencrypted secrets**
   ```bash
   # Add to .gitignore
   echo "ansible/.vault_pass" >> .gitignore
   echo "ansible/vault/secrets.yml" >> .gitignore
   ```

2. **Use separate vault files per environment**
   ```
   vault/
   ├── production.yml
   ├── staging.yml
   └── development.yml
   ```

3. **Rotate credentials regularly**
   ```bash
   # Change vault password quarterly
   ansible-vault rekey vault/secrets.yml
   ```

4. **Use `no_log` for sensitive tasks**
   ```yaml
   - name: Deploy secret
     copy:
       content: "{{ vault_secret }}"
       dest: /secure/path
     no_log: true
   ```

### Performance

1. **Enable pipelining**
   ```ini
   [ssh_connection]
   pipelining = True
   ```

2. **Use fact caching**
   ```ini
   [defaults]
   gathering = smart
   fact_caching = jsonfile
   fact_caching_timeout = 3600
   ```

3. **Limit host scope**
   ```bash
   ansible-playbook deploy.yml -l app-server-01
   ```

### Idempotency

Always write idempotent tasks:

```yaml
# Good - idempotent
- name: Create directory
  file:
    path: /opt/app
    state: directory

# Bad - not idempotent
- name: Create directory
  command: mkdir /opt/app
```

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
ansible all -m ping

# Verbose output
ansible all -m ping -vvv

# Specific user
ansible all -m ping -u deploy --private-key ~/.ssh/deploy_rsa
```

### Vault Problems

```bash
# Wrong password error
ERROR! Decryption failed (no vault secrets would be found)

# Solution: verify .vault_pass content or use --ask-vault-pass
ansible-playbook deploy.yml --ask-vault-pass
```

### Permission Denied

```bash
# SSH key not found
ansible-playbook deploy.yml --private-key ~/.ssh/correct-key

# Sudo issues
ansible-playbook deploy.yml --ask-become-pass
```

### Debug Mode

```bash
# Maximum verbosity
ansible-playbook deploy.yml -vvvv

# Check what would change
ansible-playbook deploy.yml --check --diff

# Step through tasks
ansible-playbook deploy.yml --step
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ansible
        run: pip install ansible
      
      - name: Deploy SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.DEPLOY_SSH_KEY }}" > ~/.ssh/deploy_rsa
          chmod 600 ~/.ssh/deploy_rsa
      
      - name: Create vault password
        run: echo "${{ secrets.VAULT_PASSWORD }}" > ansible/.vault_pass
      
      - name: Deploy services
        run: |
          cd ansible
          ansible-playbook playbooks/deploy-services.yml \
            -e "git_branch=${{ github.ref_name }}"
```

### GitLab CI

```yaml
deploy:production:
  stage: deploy
  only:
    - tags
  script:
    - pip install ansible
    - echo "$VAULT_PASSWORD" > ansible/.vault_pass
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/deploy_rsa
    - chmod 600 ~/.ssh/deploy_rsa
    - cd ansible
    - ansible-playbook playbooks/deploy-services.yml
```

## Advanced Topics

### Dynamic Inventory

For cloud environments:

```bash
# Install AWS plugin
pip install boto3

# Configure AWS inventory
# aws_ec2.yml
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:Environment: production

# Use it
ansible-playbook deploy.yml -i aws_ec2.yml
```

### Custom Modules

Create reusable automation:

```python
# library/microservice_health.py
from ansible.module_utils.basic import AnsibleModule

def main():
    module = AnsibleModule(
        argument_spec=dict(
            service=dict(required=True, type='str'),
        )
    )
    # Custom health check logic
    module.exit_json(changed=False, healthy=True)

if __name__ == '__main__':
    main()
```

### Ansible Galaxy

Share and use community roles:

```bash
# Install role
ansible-galaxy install geerlingguy.docker

# Use in playbook
- hosts: all
  roles:
    - geerlingguy.docker
```

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Vault Guide](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Security Best Practices](https://docs.ansible.com/ansible/latest/reference_appendices/security.html)

