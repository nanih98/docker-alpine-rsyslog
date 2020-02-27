FROM alpine:latest

LABEL name="nanih98/docker-alpine-rsyslog"
LABEL MAINTAINER "Daniel Cascales Romero<devopstech253@gmail.com>"

# Install base system
RUN set -eux ;\
    apk add --update \
    rsyslog \
    logrotate \
    dcron \
    supervisor \
    python \
    py-pip \
    py-cffi \
    py-cryptography ;\
    pip install --upgrade pip 

# rsyslog: Evitem que es faci log de tot cap a messages
#RUN sed -i /etc/rsyslog.conf  -e 's%^\(\*.*/messages.*\)$%#\1%'


RUN rm -f /etc/logrotate.d/rsyslog

# rsyslog: Config custom files
COPY files/rsyslogd/rsyslog.conf /etc/rsyslog.conf
COPY files/rsyslogd/my-docker-apps.conf /etc/rsyslog.d/

# supervisord configuration:
RUN mkdir /etc/supervisord
COPY files/supervisord/supervisord.conf /etc/supervisord/supervisord.conf

EXPOSE 514 514/udp
# entrypoint
COPY files/init.sh /root/init.sh
RUN chmod +x /root/init.sh
ENTRYPOINT ["/root/init.sh"]
