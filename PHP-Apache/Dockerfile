# Use the latest Ubuntu image as the base image
FROM ubuntu:latest

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP and nano
RUN apt-get update && \
    apt-get install -y apache2 php libapache2-mod-php nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the custom Apache configuration file and enable it
COPY custom_servername.conf /etc/apache2/conf-available/
RUN a2enconf custom_servername

# Enable necessary Apache modules (if any)
# For example, to enable mod_rewrite:
RUN a2enmod rewrite

# Expose port 80 to the outside world
EXPOSE 80

# Setting the work directory.
WORKDIR /var/www/html

# Start Apache in the foreground when the container runs
CMD ["apachectl", "-D", "FOREGROUND"]
