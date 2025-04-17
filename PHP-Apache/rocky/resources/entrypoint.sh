#!/bin/bash
set -e

# Start PHP-FPM
#echo "Starting PHP-FPM..."
php-fpm -D

# Start Apache
#echo "Starting Apache..."
exec /usr/sbin/httpd -D FOREGROUND
