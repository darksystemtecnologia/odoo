#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo Database is now available

# 1) Migração de schema (uma passada)
if [ "${ODOO_RUN_MIGRATION:-1}" = "1" ]; then
  echo "Running one-shot module upgrade (-u all)..."
  odoo -c /etc/odoo/odoo.conf -u all --stop-after-init
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
