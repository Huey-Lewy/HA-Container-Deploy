#!/usr/bin/env bash
set -euo pipefail

DB_NAME=ha_app
ROOT_PW=$(cat /run/secrets/db_root_password)

# Wait for MariaDB to accept connections
until mysqladmin ping -uroot -p"$ROOT_PW" --silent; do
  sleep 1
done

# Escape quotes and newline-encode the page
PAGE_CONTENT=$(sed "s/'/''/g" /docker-entrypoint-initdb.d/index.html \
  | awk '{printf "%s\\n", $0}')

# Insert the blob
mysql -uroot -p"$ROOT_PW" "$DB_NAME" -e \
  "INSERT INTO pages (name, content) VALUES ('index', '$PAGE_CONTENT');"
