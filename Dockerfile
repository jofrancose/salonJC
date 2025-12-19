FROM php:8.2-apache

# 1. Instalar dependencias del sistema y Node.js para Tailwind
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 2. Habilitar mod_rewrite de Apache (Vital para Laravel)
RUN a2enmod rewrite

# 3. Configurar Document Root a /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf | sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/conf-available/*.conf

# 4. Instalar extensiones PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 5. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 6. Copiar archivos del proyecto
WORKDIR /var/www/html
COPY . .

# 7. Instalar dependencias PHP y Compilar Assets (Tailwind)
RUN composer install --optimize-autoloader --no-dev
RUN npm install && npm run build

# 8. Permisos correctos para www-data
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
