#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
VOLUME=mariadb_data
IMAGES=(ha-app-db:latest ha-app-web:latest)

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

echo "Tearing down stack '$STACK_NAME' from '$ROOT_DIR'..."

# 1. Remove stack if present
if docker stack ls --format '{{.Name}}' | grep -qx "$STACK_NAME"; then
  docker stack rm "$STACK_NAME" || true
else
  echo "Stack '$STACK_NAME' not present."
fi

# 2. Wait up to 60s for all services of this stack to vanish
echo -n "Waiting for stack resources to stop"
for _ in $(seq 1 60); do
  if ! docker service ls --format '{{.Name}}' | grep -q "^${STACK_NAME}_" 2>/dev/null; then
    break
  fi
  echo -n "."
  sleep 1
done
echo

# 3a. Remove both external and stack-scoped networks (best-effort)
for net in "$NETWORK" "${STACK_NAME}_${NETWORK}"; do
  if docker network inspect "$net" >/dev/null 2>&1; then
    docker network rm "$net" 2>/dev/null || true
  fi
done

# 4. Remove both external and stack-scoped networks (retry briefly, in case it was busy)
for vol in "$VOLUME" "${STACK_NAME}_${VOLUME}"; do
  for _ in $(seq 1 10); do
    if docker volume rm "$vol" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
done

# 5. Remove built images (optional; keeps things clean for a full rebuild)
for img in "${IMAGES[@]}"; do
  docker rmi "$img" 2>/dev/null || true
done

# 6. Remove .env so next run regenerates fresh creds
rm -f "$ENV_FILE"
echo "Teardown complete."