FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    ODOO_HOME=/opt/odoo \
    ODOO_DATA=/var/lib/odoo \
    ODOO_CONF=/etc/odoo/odoo.conf \
    ODOO_EXTRA_ADDONS=/mnt/extra-addons

# Dependências de sistema (Trixie)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc build-essential \
    libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libpq-dev \
    libjpeg-dev zlib1g-dev libffi-dev libjpeg62-turbo libtiff6 libopenjp2-7 \
    xz-utils curl ca-certificates fontconfig \
    nodejs npm wkhtmltopdf fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

# Usuário e pastas
RUN useradd -ms /bin/bash odoo \
 && mkdir -p ${ODOO_HOME} ${ODOO_DATA} ${ODOO_EXTRA_ADDONS} /etc/odoo \
 && chown -R odoo:odoo ${ODOO_HOME} ${ODOO_DATA} ${ODOO_EXTRA_ADDONS} /etc/odoo

# Odoo 19 (community)
WORKDIR ${ODOO_HOME}
RUN git clone --depth=1 --branch=19.0 https://github.com/odoo/odoo.git ${ODOO_HOME}/src

# Python deps
WORKDIR ${ODOO_HOME}/src
RUN pip install --no-cache-dir -r requirements.txt

# (Opcional) utilitários front
RUN npm i -g rtlcss postcss postcss-cli

# Entrypoint
WORKDIR ${ODOO_HOME}
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8069
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl -fsS http://127.0.0.1:${PORT:-8069}/web || exit 1

USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash", "-lc", "python ${ODOO_HOME}/src/odoo-bin -c ${ODOO_CONF} --http-port=${PORT:-8069}"]
