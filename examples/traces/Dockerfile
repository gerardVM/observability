# Use an official PHP image
FROM php:8.1-cli

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /app

# Copy the application code
COPY . .

# Copy composer.json and install OpenTelemetry
COPY composer.json ./
RUN composer install

# Run the PHP script (adjust entrypoint as needed)
CMD ["php", "-S", "0.0.0.0:8080", "/app/index.php"]
