# Contributing

## Development Workflow

### Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd dev_ops_bar

# Copy environment template
cp env.example .env

# Optional: create local override
cp docker-compose.override.yml.example docker-compose.override.yml
```

### Running Services

```bash
# Start infrastructure first
make infra-up

# Wait for databases to be ready, then start services
make services-up

# Or start everything at once
make up
```

### Making Changes

1. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes

3. Test locally
   ```bash
   make health
   docker compose logs -f <service-name>
   ```

4. Clean up before committing
   ```bash
   make down
   ```

### Environment Variables

Always use `.env` file for local development. Never commit sensitive credentials.

Use `env.example` as a template. Default values in docker-compose files should work for development but use placeholder passwords.

### Docker Best Practices

- Use specific version tags, not `latest` in production
- Always include healthchecks for services
- Use named volumes for data persistence
- Limit resource usage when needed
- Keep images small (use alpine variants)

### Network Architecture

All services communicate via the `db-network` bridge network. Services reference each other by container name for DNS resolution.

### Adding New Services

1. Add service definition to appropriate compose file
2. Update `.env.example` with any new variables
3. Add healthcheck configuration
4. Update README.md service table
5. Test with `make up` and `make health`

### Troubleshooting

```bash
# View all logs
make logs

# Check specific service
docker logs <container-name>

# Inspect network
docker network inspect db-network

# Check volumes
docker volume ls

# Access database directly
docker exec -it servicedb psql -U testuser -d datasource_servicedb

# Restart specific service
docker compose -f docker-compose-files/docker-compose-services.yml restart middleware-service
```

### Code Quality

- Keep docker-compose files organized and consistent
- Use environment variables for configuration
- Document any non-obvious configuration choices
- Test changes before pushing

### Commit Messages

Use conventional commits:
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `chore:` maintenance
- `refactor:` code refactoring

