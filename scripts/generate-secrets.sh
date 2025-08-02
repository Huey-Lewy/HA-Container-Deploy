#!/usr/bin/env bash
set -euo pipefail

SECRETS=(db_root_password db_user_password)

# 1. Build random passwords
root_pw=$(date +%s%N | sha256sum | cut -c1-32)
user_pw=$(date +%s%N | sha256sum | cut -c1-32)

# 2. Remove old secrets
for secret in "${SECRETS[@]}"; do
  if docker secret inspect "$secret" &>/dev/null; then
    docker secret rm "$secret"
  fi
done

# 3. Create new secrets
echo "$root_pw" | docker secret create db_root_password -
echo "$user_pw" | docker secret create db_user_password -

echo "Created secrets: ${SECRETS[*]}"
