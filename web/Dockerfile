FROM php:8.2-fpm

# Install NGINX and curl
RUN apt-get update \
    && apt-get install -y nginx curl \
    && rm -rf /var/lib/apt/lists/*

# Have PHP-FPM listen on TCP 127.0.0.1:9000
RUN sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/www.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

# Copy application and install dependencies
WORKDIR /var/www/html
COPY web/src/ .
RUN composer install --no-dev --optimize-autoloader

# Load NGINX config and fix permissions
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Health check endpoint for Caddy
HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
  CMD curl -f http://localhost/health

# Start PHP-FPM (daemon) then NGINX in foreground
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
