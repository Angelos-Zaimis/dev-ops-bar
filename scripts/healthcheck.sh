#!/bin/bash

set -e

SERVICES=("servicedb" "inventorydb" "zookeeper" "kafka" "middleware-service" "middleware-inventory")
FAILED=0

echo "Checking service health..."
echo "=========================="

for service in "${SERVICES[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        status=$(docker inspect --format='{{.State.Health.Status}}' "${service}" 2>/dev/null || echo "no healthcheck")
        if [ "$status" = "healthy" ] || [ "$status" = "no healthcheck" ]; then
            echo "✓ ${service}: running"
        else
            echo "✗ ${service}: ${status}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "✗ ${service}: not running"
        FAILED=$((FAILED + 1))
    fi
done

echo "=========================="

if [ $FAILED -eq 0 ]; then
    echo "All services healthy"
    exit 0
else
    echo "${FAILED} service(s) unhealthy"
    exit 1
fi

