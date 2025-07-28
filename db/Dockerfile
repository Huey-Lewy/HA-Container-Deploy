# Use official Postgres 13 image
FROM postgres:13

# Configure Postgres via environment variables (.env)
ENV POSTGRES_USER=$DB_USER
ENV POSTGRES_PASSWORD=$DB_PASS
ENV POSTGRES_DB=$DB_NAME

# Load initial schema and seed data
COPY init.sql /docker-entrypoint-initdb.d/

# Expose Postgres port
EXPOSE 5432
