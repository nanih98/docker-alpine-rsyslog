# Documentation

## Example docker compose:

```sh
    rsyslog:
        image: nanih98/docker-alpine-rsyslog:latest
        container_name: rsyslog
        restart: always
        logging:
            driver: syslog
            options:
                syslog-address: "udp://127.0.0.1:514"
                syslog-facility: "daemon"
                tag: "{{.Name}}"
        environment:
            - ROTATE_TIME=daily
            - ROTATE_NUM=7
            - ROTATE_MAXSIZE=20M
        ports:
            - "514:514/udp"
        volumes:
            # Directory where logs are saved
            - /srv/rsyslog/log/:/var/log/
            # Mapping logrotate config
            #- /srv/rsyslog/conf/logrotate.d:/etc/logrotate.d
            # Crons  
            #- /srv/rsyslog/conf/crontabs:/etc/crontabs
            # Take the localtime equal to the host
            #- /etc/timezone:/etc/timezone:ro
            #- /etc/localtime:/etc/localtime:ro
            # If you need to add more custom files to rsyslog
            # - /srv/rsyslog/conf/rsyslog:/etc/rsyslog.d/
```
# Starting the container

When the container is starting, new logrotate config are created with the env values specified in the docker-compose. (just above).(init.sh in the entrypoint).

**If you want to change this configuration, just change de init.sh or map the logrotate directory to the host and change the necessary files**


## Now you wiil see the logs like app.nameofyourcontainer.log in the directory mapped to the /var/log 

# Another example 

```yaml
version: '3.5'
services:
  mariadb:
    image: mariadb:10.4
    restart: always
    hostname: mariadb
    container_name: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: ausias@38@@@.#!?blablabla9982|root
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: pijuan@253@@.#!blablabla
    volumes:
      - /srv/mysql:/var/lib/mysql
  wordpress:
          #image: wordpress:5
    image: nanih98/wordpress:php7.4-redis
    container_name: wordpress
    hostname: wordpress
    restart: always
    ports:
      - 80:80
    volumes:
      - /srv/wordpress/html:/var/www/html
        #  - /srv/wordpress/apache2:/etc/apache2
    depends_on:
      - mariadb
    environment:
      WORDPRESS_DB_HOST: mariadb:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: pijuan@253@@.#!blablabla 
      WORDPRESS_DB_NAME: wordpress
  redis:
    image: redis:5-alpine
    container_name: redis
    restart: always
    expose:
      - 6379
    volumes:
      - /srv/redis/data:/data
    command: redis-server --appendonly yes --port 6379 --maxmemory 1gb --maxmemory-policy allkeys-lru #--requirepass "pruebas1234"
  logspout:
    image: gliderlabs/logspout
    container_name: logspout
    restart: always
    environment:
      LOGSPOUT: "ignore"
      HTTP_PORT: 81
      SYSLOG_TAG: "{{.ContainerName}}"
    command: 'syslog://172.17.0.1:514'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/hostname:/etc/host_hostname:ro
  rsyslog:
    image: nanih98/docker-alpine-rsyslog:latest
    container_name: rsyslog
    restart: always
    environment:
        - ROTATE_TIME=daily
        - ROTATE_NUM=7
        - ROTATE_MAXSIZE=20M
        - LOGSPOUT=ignore
    ports:
        - "514:514/udp"
    volumes:
        # Directory where logs are saved
        - /srv/rsyslog/log/:/var/log/
