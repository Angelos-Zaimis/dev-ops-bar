#!/bin/bash

set -e

echo "This will stop all containers and remove all volumes."
read -p "Are you sure? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "Stopping services..."
docker compose -f docker-compose-files/docker-compose-services.yml down -v

echo "Stopping infrastructure..."
docker compose -f docker-compose-files/docker-compose-datasources.yml down -v

echo "Removing network..."
docker network rm db-network 2>/dev/null || true

echo "Environment reset complete. Run 'make up' to start fresh."

