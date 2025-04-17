FROM docker.io/rockylinux:9

LABEL version="1.0.0"
LABEL description="Docker Image running on Rocky Linux with PHP 8.2, Apache, MSSQL, LDAP and xDebug"
LABEL maintainer="Alexandre Ducobu"

ENV LOCATION=DOCKER

USER 0

# Install Apache (httpd)
RUN dnf -y update && \
    dnf -y upgrade && \
    dnf -y install httpd

# Install PHP-FPM, extensions and tools needed
RUN echo "enabled=0" >> /etc/yum/pluginconf.d/subscription-manager.conf

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://rpms.remirepo.net/enterprise/remi-release-9.rpm yum-utils && \
    dnf -y module reset php && \
    dnf -y module install php:remi-8.2 && \
    dnf -y update

RUN curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/mssql-release.repo && \
    dnf remove unixODBC-utf16 unixODBC-utf16-devel && \
    ACCEPT_EULA=Y dnf install -y nano msodbcsql18 mssql-tools18 unixODBC-devel php-pdo php-pear php-devel php-sqlsrv php-ldap php-xdebug &&  \
    dnf clean all

RUN mkdir /run/php-fpm &&  \
    chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm &&  \
    chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm && \
    mkdir -p /data/Logs /data/cache /data/changelog /data/reports &&  \
    echo "clear_env = no" >> /etc/php-fpm.conf

# Copy PHP settings (for php.ini)
COPY resources/docker-php-ext-ini.ini /etc/php.d/
COPY resources/docker-php-ext-xdebug.ini /etc/php.d/

# Overwrite PHP-Apache settings
COPY resources/php.conf /etc/httpd/conf.d/php.conf

# Overwrite PHP-FPM settings
COPY resources/www.conf /etc/php-fpm.d/www.conf

# Set permissions
RUN chown -R apache:apache /var/www/html

# Avoid 'apache2: Could not reliably determine the server's fully qualified domain name, using 10.89.3.2. Set the 'ServerName' directive globally to suppress this message'
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

# Copy entrypoint script (needed to start PHP and httpd)
COPY resources/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set user (commented because we have some access issues when using it, and because it's only for development)
#USER 1001

# Setting the work directory.
WORKDIR /var/www/html

# Start bith PHP-FPM and Apache
CMD ["/entrypoint.sh"]
