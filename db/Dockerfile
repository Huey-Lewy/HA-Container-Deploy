FROM mariadb:11.8

# Copy your init script and HTML page
COPY init.sql /docker-entrypoint-initdb.d/
COPY index.html /docker-entrypoint-initdb.d/
COPY load_index_html.sh /docker-entrypoint-initdb.d/

# Make loader script executable
RUN chmod +x /docker-entrypoint-initdb.d/load_index_html.sh
