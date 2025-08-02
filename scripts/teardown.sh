#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
VOLUME=mariadb_data
SECRETS=(db_root_password db_user_password)

# 1. Remove stack
docker stack rm "$STACK_NAME"

# 2. Wait for services to stop
sleep 5

# 3. Remove secrets
for secret in "${SECRETS[@]}"; do
  docker secret rm "$secret" 2>/dev/null || true
done

# 4. Remove network and volume
docker network rm "$NETWORK" 2>/dev/null || true
docker volume rm "$VOLUME" 2>/dev/null || true

echo "Tore down stack and cleaned up resources"
