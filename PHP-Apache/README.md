# PHP-Apache

There are two kinds of images:

- [debian](debian): the original Docker image, based on the official PHP Apache image (_based on Debian_)
- [rocky](rocky): the new Docker image, based on [Rocky Linux](https://rockylinux.org) and closer to the image we'd use on OpenShift

To build the image, just go to the correct directory and execute:

```shell
docker compose up -d
```

## Images info

### Image (`Dockerfile`)
This image is based on the latest PHP-Apache image for PHP 8.2 (`php:8.2-apache`).  
We install some tools, like xDebug, nano…

We can enable any necessary Apache module.  
For example, we enable `mod_rewrite`.

Then, we expose the port 80 and set the working directory: `/var/www/html`.

Finally, we start Apache in the foreground.

### `compose.yaml`
Docker compose is a configuration tool used for running multiple containers at once.  
In this case, we only have one container to run.

We tell it to build the image of the current folder, and to name the image `php-apache-image`.  
We bind the container port `80` to the host `8080`.

Then, we give the container a name (`php-apache`), and a hostname (`server_on_docker`).

After that, we bind the local directory (`/local/path/to/source`) to the one of the container (`/var/www/html`).

### Versions (tag)
If we want to add a version other that the default `latest`, we have to use this command: `docker build -t php-apache-image:version .`.  
Of course, it is possible to set multiple tags: `docker build -t php-apache-image -t php-apache-image:version .`.

In that case, we'll have to remove the line `build: .` from the `compose.yaml` file.  
To start the container in detached mode, we can use `docker-compose up -d`.  
To stop it, the command is `docker-compose down`.

## Error logs

For Debian, there are no error logs by default, so we had to create `/var/log/php-errors.log`, and activate them via `php.ini`.

For PHP-FPM (Rocky), the default path is `/var/log/php-fpm/www-error.log`, so it is not needed in the `.ini` file.

## For PHP-FPM (Rocky Linux)

### entrypoint.sh

From time to time (_on Windows_), the container cannot start with this error in the logs: `exec /entrypoint.sh: no such file or directory`.

It appears that, being created on Windows, the line endings character is wrong.  
To fix it, we only have to execute:

```shell
dos2unix entrypoint.sh
```

### Timeouts

We have a lot of timeout issues.  
For example, debugging will finish with a timeout error if it takes too long (_maybe 1 minute_)...

After some changes, we now have the timeout set to 10 minutes (_on Debian, it seems no timeout is set_).

#### What was changed to make it work?

All changes were done without any positive result.  
After updating `php.conf`, we even got a `Service Unavailable` error...

Then, setting `listen = 127.0.0.1:9000` fixed everything.

##### www.conf

We had to add a custom `/etc/php-fpm.d/www.conf` containing these changes:

1. `request_terminate_timeout = 600` by default, it is commented and set to `request_terminate_timeout = 0`
2. `listen = 127.0.0.1:9000` instead of the default `listen = /run/php-fpm/www.sock`
3. make sure we had `listen.allowed_clients = 127.0.0.1` (_default value_)

##### php.conf

We also had to use a custom `/etc/httpd/conf.d/php.conf` which makes the link between PHP-FPM and Apache.

We've added these lines at the end of the file, to set the timeout to 10 minutes:

```
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>

ProxyTimeout 600
Timeout 600
```

##### httpd.conf

To have the root folder of the SID following the `.htaccess`, we had to update (_and override_) `/etc/httpd/conf/httpd.conf` which also make the link between PHP-FPM and Apache.

We've put the `AllowOverride` to `All`:

```
# Further relax access to the default document root:
<Directory "/var/www/html">
    #
    # Possible values for the Options directive are "None", "All",
    # or any combination of:
    #   Indexes Includes FollowSymLinks SymLinksifOwnerMatch ExecCGI MultiViews
    #
    # Note that "MultiViews" must be named *explicitly* --- "Options All"
    # doesn't give it to you.
    #
    # The Options directive is both complicated and important.  Please see
    # http://httpd.apache.org/docs/2.4/mod/core.html#options
    # for more information.
    #
    Options FollowSymLinks

    #
    # AllowOverride controls what directives may be placed in .htaccess files.
    # It can be "All", "None", or any combination of the keywords:
    #   Options FileInfo AuthConfig Limit
    #
    AllowOverride All

    #
    # Controls who can get stuff from this server.
    #
    Require all granted
</Directory>
```

Also, to avoid `apache2: Could not reliably determine the server's fully qualifies domain name`, we have set the `ServerName` directive globally:

```
ServerName localhost
```
