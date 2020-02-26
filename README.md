Container per controlar els logs d'altres dockers i serveis amb el tag.

La configuració ja separa per tag i servei els logs.

Per a que un docker utilitzi aquest rsyslog cal afegir els paràmetres següents de un service de docker-compose:

```sh
...
    logging:
        driver: syslog
        options:
            syslog-address: "udp://[ip_rsyslog]:514"
            syslog-facility: "daemon"
            tag: "{{.Name}}"
...
```
Sempre usem el facility de daemon.

Execució del docker amb docker-compose:

```sh
    rsyslog:
        image: ackstorm/alpine-rsyslog:ack3
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
            - "0.0.0.0:514:514/udp"
        volumes:
            # Directori de logs
            - /srv/rsyslog/log/:/var/log/
            # Config adicional logrotate
            #- /srv/rsyslog/conf/logrotate.d:/etc/logrotate.d
            # crons 
            #- /srv/rsyslog/conf/crontabs:/etc/crontabs
            # Si necessitem exportar el /dev/log
            #- /srv/rsyslog/dev/:/dev/:rw
            # Si la hora no es GMT+0:
            #- /etc/timezone:/etc/timezone:ro
            #- /etc/localtime:/etc/localtime:ro
            # Si necessitem afegir més configs de rsyslog
            #- /srv/rsyslog/etc/custom.conf:/etc/rsyslog.d/99-custom.conf:ro
```

Al arrancar el docker se copiarán los archivos de configuración /etc/logrotate.d/logrotate.conf y /etc/crontabs/crontabs.

En el caso de logrotate.conf se podrán usar las variables de entorno siempre que mantengamos el archivo base. Pero se rotarán todos los archivos igual (*.log).
Si queremos realizar diferentes politicas de rotado eliminar el tag "# default ackstorm logrotate", quitar "/var/log/*.log" y añadir los archivos de config que queramos.

Podemos añadir crons diferentes montando en un volumen y modificando el archivo root. No hay que poner el usuario ya que es el cron de root.
