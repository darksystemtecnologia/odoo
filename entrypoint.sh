#!/usr/bin/env bash
set -e

# Defaults sensatos
: "${ODOO_ADMIN_PASS:=change_me_masterpass}"
: "${ODOO_DB_HOST:=${PGHOST:-postgres.railway.internal}}"
: "${ODOO_DB_PORT:=${PGPORT:-5432}}"
: "${ODOO_DB_USER:=${PGUSER:-odoo}}"
: "${ODOO_DB_PASSWORD:=${PGPASSWORD:-odoo}}"
: "${ODOO_DB_NAME:=${PGDATABASE:-odoo}}"
: "${ODOO_WORKERS:=2}"
: "${ODOO_MAX_CRON_THREADS:=1}"
: "${ODOO_LIMIT_TIME_CPU:=60}"
: "${ODOO_LIMIT_TIME_REAL:=120}"
: "${ODOO_PROXY_MODE:=True}"
: "${ODOO_LOG_LEVEL:=info}"
: "${ODOO_LONGPOLLING_PORT:=8072}"
: "${ODOO_DATA_DIR:=/var/lib/odoo}"
: "${ODOO_ADDONS_PATH:=/opt/odoo/src/addons,/mnt/extra-addons}"
: "${PORT:=8069}"

# SMTP (opcionais)
: "${SMTP_SERVER:=}"
: "${SMTP_PORT:=587}"
: "${SMTP_USER:=}"
: "${SMTP_PASSWORD:=}"
: "${SMTP_SSL:=False}"   # True/False
: "${MAIL_CATCHALL_DOMAIN:=}"  # ex: example.com

mkdir -p "$(dirname "${ODOO_CONF}")"
mkdir -p "${ODOO_DATA_DIR}"

cat > "${ODOO_CONF}" <<EOF
[options]
admin_passwd = ${ODOO_ADMIN_PASS}
data_dir = ${ODOO_DATA_DIR}
addons_path = ${ODOO_ADDONS_PATH}
db_host = ${ODOO_DB_HOST}
db_port = ${ODOO_DB_PORT}
db_user = ${ODOO_DB_USER}
db_password = ${ODOO_DB_PASSWORD}
# Você pode travar DB específico (opcional):
# db_name = ${ODOO_DB_NAME}

log_level = ${ODOO_LOG_LEVEL}
proxy_mode = ${ODOO_PROXY_MODE}
workers = ${ODOO_WORKERS}
max_cron_threads = ${ODOO_MAX_CRON_THREADS}
limit_time_cpu = ${ODOO_LIMIT_TIME_CPU}
limit_time_real = ${ODOO_LIMIT_TIME_REAL}
longpolling_port = ${ODOO_LONGPOLLING_PORT}

# SMTP (se fornecer variáveis)
smtp_server = ${SMTP_SERVER}
smtp_port = ${SMTP_PORT}
smtp_user = ${SMTP_USER}
smtp_password = ${SMTP_PASSWORD}
smtp_ssl = ${SMTP_SSL}
mail.catchall.domain = ${MAIL_CATCHALL_DOMAIN}
EOF

echo "[entrypoint] odoo.conf gerado em ${ODOO_CONF}"
exec "$@"
