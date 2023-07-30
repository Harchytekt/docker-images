# PHP-Apache

## Image (`Dockerfile`)
This image is based on the latest Ubuntu image (`ubuntu:latest`).  
We install Apache, PHP (_and nano_).

In order to avoid the `apache2: Could not reliably determine the server's fully qualified domain name` error, 
we will set a custom servername (`ServerName localhost`).  
Here, we create a `custom_servername.conf` that we will copy in `/etc/apache2/conf-available/`.  
For it to be active, we then execute `RUN a2enconf custom_servername`.

We can enable any necessary Apache module.  
For example, we enable `mod_rewrite`.

Then, we expose the port 80 and set the working directory: `/var/www/html`.

Finally, we start Apache in the foreground.

## `compose.yaml`
Docker compose is a configuration tool used for running multiple containers at once.  
In this case, we only have one container to run.

We tell it to build the image of the current folder, and to name the image `php-apache-image`.  
We bind the container port `80` to the host `8080`.

Then, we give the container a name (`php-apache`), and a hostname (`server_on_docker`).

After that, we bind the local directory (`/local/path/to/source`) to the one of the container (`/var/www/html`).

## Versions (tag)
If we want to add a version other that the default `latest`, we have to use this command: `docker build -t php-apache-image:version .`.  
Of course, it is possible to set multiple tags: `docker build -t php-apache-image -t php-apache-image:version .`.

In that case, we'll have to remove the line `build: .` from the `compose.yaml` file.  
To start the container in detached mode, we can use `docker-compose up -d`.  
To stop it, the command is `docker-compose down`.
