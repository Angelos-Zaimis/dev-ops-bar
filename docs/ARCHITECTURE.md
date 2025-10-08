# Architecture Documentation

## Overview

This project implements a microservices architecture using Docker Compose for orchestration. It demonstrates key DevOps and distributed systems concepts including service isolation, event-driven architecture, and infrastructure as code.

## System Components

### Microservices Layer

#### Middleware Service
- **Port**: 8881
- **Database**: ServiceDB (PostgreSQL)
- **Purpose**: Core business logic service
- **Communication**: REST API, Kafka messaging
- **Framework**: Spring Boot

#### Middleware Inventory
- **Port**: 8882
- **Database**: InventoryDB (PostgreSQL)
- **Purpose**: Inventory management service
- **Communication**: REST API, Kafka messaging
- **Framework**: Spring Boot

### Data Layer

#### ServiceDB
- **Type**: PostgreSQL 16 (Alpine)
- **Port**: 5009
- **Purpose**: Primary data store for middleware-service
- **Persistence**: Named volume `servicedb_data`

#### InventoryDB
- **Type**: PostgreSQL 16 (Alpine)
- **Port**: 5010
- **Purpose**: Primary data store for middleware-inventory
- **Persistence**: Named volume `inventorydb_data`

### Message Broker

#### Apache Kafka
- **Port**: 9092
- **Purpose**: Asynchronous event streaming between services
- **Dependencies**: Zookeeper
- **Persistence**: Named volume `kafka_data`

#### Zookeeper
- **Port**: 2181
- **Purpose**: Kafka cluster coordination
- **Persistence**: Named volumes for data and logs

## Communication Patterns

### Synchronous Communication
Services communicate via REST APIs using container DNS resolution:
- `middleware-service` → `middleware-inventory:8082`
- `middleware-inventory` → `middleware-service:8080`

### Asynchronous Communication
Event-driven messaging through Kafka topics for:
- Eventual consistency
- Decoupling services
- Event sourcing patterns

## Network Architecture

### Bridge Network: `db-network`
- Isolated network for all services
- DNS resolution by container name
- No external exposure except mapped ports

### Port Mapping Strategy
All services bind to localhost (127.0.0.1) to prevent external network exposure in development.

## Data Persistence

### Volume Strategy
- **Database volumes**: Persist database files across restarts
- **Log volumes**: Centralized application logging
- **Kafka volumes**: Message retention and coordinator state

### Backup Strategy
Regular backups via `backup-databases.sh`:
- Automated pg_dump for both databases
- 7-day retention policy
- Timestamped backup files

## Configuration Management

### Environment Variables
Configuration externalized via `.env` file:
- Database credentials
- Service ports
- Kafka settings
- Application profiles

### Default Values
All docker-compose files include sensible defaults using `${VAR:-default}` syntax for graceful degradation.

## Health Monitoring

### Service Health Checks
- **PostgreSQL**: `pg_isready` checks
- **Kafka**: Broker API version checks
- **Spring Boot**: Actuator health endpoints

### Monitoring Script
`healthcheck.sh` provides automated health status reporting.

## Deployment Workflow

```
1. Infrastructure Layer (docker-compose-datasources.yml)
   ├── PostgreSQL databases
   ├── Zookeeper
   └── Kafka

2. Application Layer (docker-compose-services.yml)
   ├── Middleware Service
   └── Middleware Inventory
```

## Scalability Considerations

### Horizontal Scaling
- Services can be scaled using `docker compose up --scale`
- Kafka handles message distribution across instances
- Database connection pooling configured

### Vertical Scaling
- Java heap sizes configurable via `JAVA_OPTS`
- PostgreSQL resources tunable via environment variables

## Security Practices

- No credentials in version control
- Network isolation via bridge network
- Localhost-only port binding
- OAuth2 integration ready
- Environment-based secrets management

## Development vs Production

### Development (Current)
- Single Kafka broker
- Single database instances
- Local-only network binding
- Verbose logging
- Spring DevTools enabled

### Production Considerations
- Multiple Kafka brokers
- Database replication
- Reverse proxy (nginx/traefik)
- TLS/SSL encryption
- Monitoring stack (Prometheus/Grafana)
- Log aggregation (ELK stack)
- Secrets management (Vault)

## CI/CD Integration

GitHub Actions workflow validates:
- Docker Compose syntax
- Service configuration
- Infrastructure startup

## Disaster Recovery

### Backup
- Automated database dumps
- Volume snapshots capability
- Configuration in version control

### Recovery
- `reset-environment.sh` for clean slate
- Restore from SQL dumps
- Rebuild from docker-compose files

## Performance Optimization

- Alpine-based images for smaller footprint
- Named volumes for I/O performance
- Connection pooling in services
- Kafka batching configured
- Health check intervals tuned

## Future Enhancements

- Service mesh (Istio/Linkerd)
- Distributed tracing (Jaeger)
- API Gateway (Kong/Envoy)
- Container orchestration (Kubernetes)
- GitOps workflow (ArgoCD)

