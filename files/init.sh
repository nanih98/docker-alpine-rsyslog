#!/bin/sh

# Logrotate with env config 
[ "x${ROTATE_TIME}" != "daily weekly" ] || ROTATE_TIME="daily"
[ "x${ROTATE_NUM}" == "x" ] || ROTATE_NUM="30"
[ "x${ROTATE_MAXSIZE}" == "x" ] || ROTATE_MAXSIZE="100M"

if [ ! -f /etc/logorate.d/rsyslog ]; then
echo -e  "Creating logrotate file\n"		
echo DEBUG: ROTATE_NUM=${ROTATE_NUM}
echo DEBUG: ROTATE_TIME=${ROTATE_TIME} 
echo DEBUG: ROTATE_MAXSIZE=${ROTATE_MAXSIZE}

# Create the logrotate.conf file
echo "
# Default logrotate conf for rsyslog container
/var/log/messages
/var/log/syslog
/var/log/*.log {
rotate ${ROTATE_NUM}
${ROTATE_TIME}
size ${ROTATE_MAXSIZE}
missingok
notifempty
delaycompress
compress
copytruncate
postrotate
	pgrep rsyslogd | xargs kill -HUP
endscript
}
" > /etc/logrotate.d/rsyslog
else
	echo "Logrotate config for rsyslog not found" #It shouldn't exist as we remove the default config in the Dockerfile
fi

# Create cron to execute logrotate with the file that we previosuly create
echo "*/5 * * * * logrotate /etc/logrotate.d/rsyslog" >> /etc/crontabs/root

# Execute supervisord daemon to start rsyslogd and crond processes
exec /usr/bin/supervisord -n -c /etc/supervisord/supervisord.conf
