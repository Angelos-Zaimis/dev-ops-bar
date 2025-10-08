# Microservices Infrastructure

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=flat&logo=postgresql&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=flat&logo=apachekafka)
![Spring](https://img.shields.io/badge/spring-%236DB33F.svg?style=flat&logo=spring&logoColor=white)

A production-ready microservices architecture demonstrating containerization, service orchestration, and event-driven communication patterns.

## Architecture

```
┌─────────────────────┐      ┌─────────────────────┐
│ Middleware Service  │◄────►│ Middleware Inventory│
│    (Port 8881)      │      │    (Port 8882)      │
└──────────┬──────────┘      └──────────┬──────────┘
           │                             │
           ▼                             ▼
    ┌──────────┐                  ┌──────────┐
    │ServiceDB │                  │InventoryDB│
    │(Port 5009)│                 │(Port 5010)│
    └──────────┘                  └──────────┘
           │                             │
           └─────────┬───────────────────┘
                     ▼
              ┌─────────────┐
              │    Kafka    │
              │(Port 9092)  │
              └─────────────┘
```

## Tech Stack

- **Databases**: PostgreSQL 16
- **Message Broker**: Apache Kafka 7.1.0
- **Services**: Java Spring Boot applications
- **Orchestration**: Docker Compose
- **Automation**: Ansible
- **Secrets Management**: Ansible Vault
- **Network**: Custom bridge network for service isolation

## Quick Start

### Docker Compose (Local Development)

```bash
# Start infrastructure (databases, Kafka)
make infra-up

# Build and start services
make services-up

# Start everything
make up

# View logs
make logs

# Stop all services
make down
```

### Ansible (Production Deployment)

```bash
cd ansible

# Initial setup
./setup-ansible.sh

# Deploy to servers
ansible-playbook playbooks/setup-infrastructure.yml
ansible-playbook playbooks/manage-secrets.yml
ansible-playbook playbooks/deploy-services.yml
```

## Manual Setup

```bash
# Start datasources
docker compose -f docker-compose-files/docker-compose-datasources.yml up -d

# Start microservices
docker compose -f docker-compose-files/docker-compose-services.yml up -d
```

## Service Endpoints

| Service              | URL                          | Swagger UI                           |
|----------------------|------------------------------|--------------------------------------|
| Middleware Service   | http://localhost:8881        | http://localhost:8881/swagger-ui     |
| Middleware Inventory | http://localhost:8882        | http://localhost:8882/swagger-ui     |
| ServiceDB            | localhost:5009               | -                                    |
| InventoryDB          | localhost:5010               | -                                    |
| Kafka                | localhost:9092               | -                                    |

## Configuration

Copy `env.example` to `.env` and adjust values as needed:

```bash
cp env.example .env
```

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── docker-compose-check.yml
├── ansible/                        # Ansible automation
│   ├── playbooks/
│   ├── inventory/
│   ├── group_vars/
│   ├── vault/
│   ├── templates/
│   └── ansible.cfg
├── docker-compose-files/
│   ├── docker-compose-datasources.yml
│   └── docker-compose-services.yml
├── docs/
│   └── ARCHITECTURE.md
├── scripts/
│   ├── backup-databases.sh
│   ├── healthcheck.sh
│   └── reset-environment.sh
├── .dockerignore
├── .editorconfig
├── .gitignore
├── CONTRIBUTING.md
├── env.example
├── LICENSE
├── Makefile
└── README.md
```

For detailed architecture information, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

For Ansible automation, see [ansible/README.md](ansible/README.md).

## Features Demonstrated

- **Service Mesh**: Inter-service communication via REST
- **Event Streaming**: Kafka-based async messaging
- **Database per Service**: Isolated data stores
- **Service Discovery**: Container DNS resolution
- **Health Checks**: Automated service monitoring
- **Volume Management**: Persistent data storage
- **Network Isolation**: Dedicated bridge network
- **Environment Configuration**: Externalized config via env vars
- **Log Aggregation**: Centralized logging
- **Infrastructure as Code**: Ansible playbooks for automation
- **Secrets Management**: Ansible Vault for sensitive data
- **SSH Key Management**: Automated key deployment
- **Automated Backups**: Encrypted database backups

## Development

```bash
# View service logs
docker compose -f docker-compose-files/docker-compose-services.yml logs -f

# Restart a specific service
docker compose -f docker-compose-files/docker-compose-services.yml restart middleware-service

# Access database
docker exec -it servicedb psql -U testuser -d datasource_servicedb

# Check Kafka topics
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092

# Backup databases
./scripts/backup-databases.sh

# Reset environment
./scripts/reset-environment.sh
```

## Monitoring

```bash
# Check service health
make health

# View resource usage
docker stats
```

## Cleanup

```bash
# Stop and remove all containers
make clean

# Remove volumes (WARNING: deletes data)
make clean-volumes
```

## Prerequisites

- Docker Engine 20.10+
- Docker Compose V2
- Ansible 2.14+ (for automation)
- Python 3.8+
- 4GB+ available RAM

## License

MIT

