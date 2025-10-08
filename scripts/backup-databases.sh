#!/bin/bash

set -e

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "Starting database backups..."

docker exec servicedb pg_dump -U testuser datasource_servicedb > "$BACKUP_DIR/servicedb_${TIMESTAMP}.sql"
echo "✓ ServiceDB backed up to $BACKUP_DIR/servicedb_${TIMESTAMP}.sql"

docker exec inventorydb pg_dump -U testuser datasource_inventorydb > "$BACKUP_DIR/inventorydb_${TIMESTAMP}.sql"
echo "✓ InventoryDB backed up to $BACKUP_DIR/inventorydb_${TIMESTAMP}.sql"

find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
echo "✓ Cleaned up backups older than 7 days"

echo "Backup completed successfully"

