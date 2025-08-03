#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
VOLUME=mariadb_data
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

echo "Deploying stack '$STACK_NAME' from '$ROOT_DIR'..."

# 1. Initialize swarm if needed
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
  docker swarm init
fi

# 2. Create overlay network
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  docker network create --driver overlay "$NETWORK"
fi

# 3. Create volume
if ! docker volume inspect "$VOLUME" >/dev/null 2>&1; then
  docker volume create "$VOLUME"
fi

# 4. (Re)generate .env so deployment can use it
"$SCRIPTS_DIR/generate-secrets.sh"

# 5. Export .env into this shell so Swarm can interpolate ${…}
ENV_FILE="$ROOT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "ERROR: .env not found at $ENV_FILE" >&2
  exit 1
fi

# 6. Build the images (Swarm ignores build: in stack files)
docker build -t ha-app-db:latest  -f "$ROOT_DIR/db/Dockerfile"  "$ROOT_DIR/db"
docker build -t ha-app-web:latest -f "$ROOT_DIR/web/Dockerfile" "$ROOT_DIR"

# 7. Deploy the stack (with variable interpolation now in effect)
docker stack deploy -c "$ROOT_DIR/docker-stack.yml" "$STACK_NAME"
echo "Deployed stack '$STACK_NAME'"