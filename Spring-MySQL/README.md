# Spring-MySQL

## Image (`Dockerfile`)
This image is based on the OpenJDK8 image (`adoptopenjdk/openjdk8`).  
We then copy the `.jar` we need to run the Spring Boot app.  

And we execute it.

## `compose.yaml`
Docker compose is a configuration tool used for running multiple containers at once.  
In this case, we have two containers to run: a "Spring Boot (JDK 8)" and a MySQL.

In order to have the two containers able to communicate, we define a network (`spring-mysql-net`).

The first service is named `spring_api_service` and will execute the SpringBoot container.  
It will build the image defined in the `Dockerfile`, map the container and host `8080` ports and depends on the second container (`mysqldb`).

The second one is then named `mysqldb` and is based on the image `mysql:8.0`.  
We map the host port `3306` to the container port `3306`.  
Then we define the database name and the user and passwords.

> ℹ️ Mapping the ports is only used for the host to communicate with the container.  
> For example, mapping the `mysqldb` port `3306` to `3307` will result in:
> - needing to use the port `3307` from the host;
> - still using the port `3306` in tha Spring Boot app in `spring_api_service`.
