FROM php:8.2-apache

LABEL version="1.2.0"
LABEL description="Docker Image with PHP 8.2, Apache, MSSQL, LDAP and xDebug"
LABEL maintainer="Alexandre Ducobu"

ENV ACCEPT_EULA=Y
ENV LOCATION=DOCKER

# Install prerequisites required for tools and extensions installed later on.
RUN apt-get update && \
    apt-get install -y apt-transport-https gnupg2 libpng-dev libzip-dev nano unzip && \
    rm -rf /var/lib/apt/lists/*

# Install prerequisites for the sqlsrv and pdo_sqlsrv PHP extensions.
# Use Ubuntu because issues with Debian
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev && \
    rm -rf /var/lib/apt/lists/*

# Retrieve the script used to install PHP extensions from the source container.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

# Install required PHP extensions and all their prerequisites available via apt.
RUN chmod uga+x /usr/bin/install-php-extensions && \
    sync && \
    install-php-extensions bcmath exif gd imagick intl ldap opcache pcntl pcov pdo_sqlsrv redis sqlsrv xdebug zip

# Activate .htaccess rewrite
RUN a2enmod rewrite

# Avoid 'apache2: Could not reliably determine the server's fully qualified domain name, using 10.89.3.2. Set the 'ServerName' directive globally to suppress this message'
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create PHP log file if doesn't exist yet
RUN touch /var/log/php-errors.log && \
    chown www-data:www-data /var/log/php-errors.log

# Copy PHP settings (for php.ini)
COPY resources/docker-php-ext-ini.ini /usr/local/etc/php/conf.d/
COPY resources/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/
COPY resources/docker-php-ext-logging.ini /usr/local/etc/php/conf.d/

# Setting the work directory.
WORKDIR /var/www/html

# build: docker build -t "my-php-app-image:1.2.0" .
# run: docker run --name container-name -d -v /local/path/to/source:/var/www/html -p 8080:80 -p 1433:1433 my-php-app-image:1.2.0
# accessible through http://localhost:8080
