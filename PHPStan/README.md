# PHPStan

[PHPStan finds bugs in your code without writing tests. It's open-source and free.](https://phpstan.org)

In order to ignore errors from PhpStorm attributes, we need to build our own image of PHPStan:

`docker build -t ghcr.io/phpstan/phpstan .`

> We keep the same name, so we don't have to change any alias

Then, we run a container with `docker run --rm -v path/to/root/dir:/app ghcr.io/phpstan/phpstan analyse /app/src`.
