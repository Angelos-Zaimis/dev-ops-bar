.PHONY: help up down infra-up infra-down services-up services-down logs health clean clean-volumes backup reset

help:
	@echo "Available commands:"
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make infra-up        - Start infrastructure only (DBs, Kafka)"
	@echo "  make infra-down      - Stop infrastructure"
	@echo "  make services-up     - Start microservices"
	@echo "  make services-down   - Stop microservices"
	@echo "  make logs            - View logs (all services)"
	@echo "  make health          - Check service health"
	@echo "  make backup          - Backup databases"
	@echo "  make reset           - Reset entire environment"
	@echo "  make clean           - Stop and remove all containers"
	@echo "  make clean-volumes   - Remove all volumes (WARNING: deletes data)"

up: infra-up services-up

down: services-down infra-down

infra-up:
	docker compose -f docker-compose-files/docker-compose-datasources.yml up -d
	@echo "Waiting for infrastructure to be ready..."
	@sleep 10

infra-down:
	docker compose -f docker-compose-files/docker-compose-datasources.yml down

services-up:
	docker compose -f docker-compose-files/docker-compose-services.yml up -d

services-down:
	docker compose -f docker-compose-files/docker-compose-services.yml down

logs:
	docker compose -f docker-compose-files/docker-compose-datasources.yml logs -f & \
	docker compose -f docker-compose-files/docker-compose-services.yml logs -f

health:
	@./scripts/healthcheck.sh || docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

clean: down
	docker compose -f docker-compose-files/docker-compose-datasources.yml down -v
	docker compose -f docker-compose-files/docker-compose-services.yml down -v

clean-volumes:
	@echo "WARNING: This will delete all data!"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker volume prune -f; \
	fi

backup:
	@./scripts/backup-databases.sh

reset:
	@./scripts/reset-environment.sh
