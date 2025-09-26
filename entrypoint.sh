#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo Database is now available

# MIGRAÇÃO: uma passada e sai
if [ "${ODOO_RUN_MIGRATION:-0}" = "1" ]; then
  echo "Running DB migration (Odoo -u base,web,auth_totp)..."
  odoo -c /etc/odoo/odoo.conf \
       -d "${ODOO_DATABASE_NAME}" \
       -u base,web,auth_totp \
       --stop-after-init
fi

exec odoo \
    --http-port="${PORT}" \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --db-filter="^${ODOO_DATABASE_NAME}$" \
    --database="${ODOO_DATABASE_NAME}" 2>&1
