#!/bin/bash
#set -eu 

if [ ! -f /app/data/ldap_email_settings.txt ]; then
        cat <<-EOF > "/app/data/ldap_email_settings.txt"
CLOUDRON_MAIL_SMTP_SERVER = ${CLOUDRON_MAIL_SMTP_SERVER}     # the mail server (relay) that apps can use. this can be an IP or DNS name
CLOUDRON_MAIL_SMTP_PORT = ${CLOUDRON_MAIL_SMTP_PORT}    # the mail server port. Currently, this port disables TLS and STARTTLS.
CLOUDRON_MAIL_SMTPS_PORT= ${CLOUDRON_MAIL_SMTPS_PORT}     # SMTPS server port.
CLOUDRON_MAIL_SMTP_USERNAME = ${CLOUDRON_MAIL_SMTP_USERNAME}   # the username to use for authentication
CLOUDRON_MAIL_SMTP_PASSWORD = ${CLOUDRON_MAIL_SMTP_PASSWORD}   # the password to use for authentication
CLOUDRON_MAIL_FROM = ${CLOUDRON_MAIL_FROM}           # the "From" address to use
CLOUDRON_MAIL_DOMAIN = ${CLOUDRON_MAIL_DOMAIN}         # the domain name to use for email sending (i.e username@domain)
--
CLOUDRON_LDAP_SERVER = ${CLOUDRON_LDAP_SERVER}
CLOUDRON_LDAP_USERS_BASE_DN = ${CLOUDRON_LDAP_USERS_BASE_DN}
CLOUDRON_LDAP_GROUPS_BASE_DN = ${CLOUDRON_LDAP_GROUPS_BASE_DN}
CLOUDRON_LDAP_BIND_PASSWORD = ${CLOUDRON_LDAP_BIND_PASSWORD}
CLOUDRON_LDAP_URL = ${CLOUDRON_LDAP_URL}
CLOUDRON_LDAP_PORT = ${CLOUDRON_LDAP_PORT}
CLOUDRON_LDAP_BIND_DN = ${CLOUDRON_LDAP_BIND_DN}
EOF
fi

chown -R cloudron:cloudron /run /app/data

exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf --nodaemon -i calibre-web


