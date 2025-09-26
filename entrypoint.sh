#!/usr/bin/env bash
set -e

echo "Waiting for database..."
while ! nc -z "${ODOO_DATABASE_HOST}" "${ODOO_DATABASE_PORT}" 2>&1; do sleep 1; done
echo "Database is now available"

: "${ODOO_ADMIN_PASSWD:?Defina a env ODOO_ADMIN_PASSWD no Railway com uma senha forte}"

# Gera o /etc/odoo/odoo.conf a partir das envs do Railway
mkdir -p /etc/odoo
cat >/etc/odoo/odoo.conf <<EOF
[options]
proxy_mode = True
http_port = ${PORT}

db_host = ${ODOO_DATABASE_HOST}
db_port = ${ODOO_DATABASE_PORT}
db_user = ${ODOO_DATABASE_USER}
db_password = ${ODOO_DATABASE_PASSWORD}
db_name = ${ODOO_DATABASE_NAME}
db_filter = ^${ODOO_DATABASE_NAME}$

list_db = False
admin_passwd = ${ODOO_ADMIN_PASSWD}

addons_path = /usr/lib/python3/dist-packages/odoo/addons,/var/lib/odoo/addons
EOF

# Sobe o Odoo lendo essa config
exec odoo -c /etc/odoo/odoo.conf 2>&1

