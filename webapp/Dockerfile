FROM php:7.4-apache

# Install required packages and tools (some intentionally outdated for vulns)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    default-mysql-client \
    wget \
    curl \
    nano \
    sudo \
    docker.io \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite

# Create a vulnerable user for privilege escalation
RUN useradd -m -s /bin/bash appuser && \
    echo "appuser:weakpass123" | chpasswd && \
    usermod -aG sudo appuser

# Set up SUID binary for privesc (intentional misconfiguration)
COPY ./setup-privesc.sh /tmp/setup-privesc.sh
RUN chmod +x /tmp/setup-privesc.sh && /tmp/setup-privesc.sh

# Copy application files
COPY ./src/ /var/www/html/

# Set permissions (intentionally weak)
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Add vulnerable cron job
RUN echo "* * * * * root /var/www/html/backup.sh" >> /etc/crontab

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
