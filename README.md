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
# Startint the container

When the container is starting, new logrotate config are created with the env values specified in the docker-compose. (just above).(init.sh in the entrypoint).

**If you want to change this configuration, just change de init.sh or map the logrotate directory to the host and change the necessary files**
