#!/usr/bin/env bash
set -euo pipefail

DB_NAME=ha_app
SECRET_FILE=/run/secrets/db_root_password

# Wait for MariaDB to accept connections
until mysqladmin ping --silent; do
  sleep 1
done

# Read root password
ROOT_PW=$(cat "$SECRET_FILE")

# Escape single quotes and join lines
PAGE_CONTENT=$(sed "s/'/''/g" /docker-entrypoint-initdb.d/index.html | awk '{printf "%s\\n", $0}')

# Insert page blob
mysql -uroot -p"$ROOT_PW" "$DB_NAME" -e \
  "INSERT INTO pages (name, content) VALUES ('index', '$PAGE_CONTENT');"
