#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
VOLUME=mariadb_data
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPTS_DIR/.."

# 1. Initialize swarm if needed
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
  docker swarm init
fi

# 2. Create overlay network
if ! docker network inspect "$NETWORK" &>/dev/null; then
  docker network create --driver overlay "$NETWORK"
fi

# 3. Create volume
if ! docker volume inspect "$VOLUME" &>/dev/null; then
  docker volume create "$VOLUME"
fi

# 4. Generate/update secrets
"$SCRIPTS_DIR/generate-secrets.sh"

# 5. Deploy stack
docker stack deploy -c "$ROOT_DIR/docker-stack.yml" "$STACK_NAME"

echo "Deployed stack '$STACK_NAME'"
