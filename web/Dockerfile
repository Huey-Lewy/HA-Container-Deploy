FROM php:8.2-fpm

# Install NGINX, curl, and remove default site
RUN apt-get update \
    && apt-get install -y nginx curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Enable PDO_MYSQL and tune PHP-FPM
RUN docker-php-ext-install pdo_mysql \
    && sed -i 's|^listen = .*|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/www.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

# Copy application code and install dependencies
WORKDIR /var/www/html
COPY web/src/ .
RUN composer install --no-dev --optimize-autoloader

# Load NGINX config
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf

# Make sure NGINX temp directories exist and is owned by www-data
RUN mkdir -p /var/lib/nginx/body \
    && chown -R www-data:www-data /var/lib/nginx /var/www/html

# Expose HTTP and add health check
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
  CMD curl -f http://localhost/health

# Start PHP-FPM then NGINX
CMD ["sh","-c","php-fpm -D && nginx -g 'daemon off;'"]