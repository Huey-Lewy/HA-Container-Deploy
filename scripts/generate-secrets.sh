#!/usr/bin/env bash
set -euo pipefail

# Determine script and repo root directories
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"

# Set database credentials
DB_NAME="ha_app"
DB_USER="ha_user"
DB_ROOT_PASSWORD="$(head -c16 /dev/urandom | od -An -tx1 | tr -d ' \n')"
DB_USER_PASSWORD="$(head -c16 /dev/urandom | od -An -tx1 | tr -d ' \n')"

# Write .env at repo root
env_path="$ROOT_DIR/.env"
cat > "$env_path" <<EOF
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_USER_PASSWORD=${DB_USER_PASSWORD}
EOF

chmod 600 "$env_path"
echo "Wrote $env_path with DB_NAME, DB_USER, DB_ROOT_PASSWORD and DB_USER_PASSWORD"