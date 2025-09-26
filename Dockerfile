# Odoo 19 roda em Python 3.11
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    ODOO_HOME=/opt/odoo \
    ODOO_DATA=/var/lib/odoo \
    ODOO_CONF=/etc/odoo/odoo.conf \
    ODOO_EXTRA_ADDONS=/mnt/extra-addons

# Dependências de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc build-essential \
    libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libpq-dev \
    libjpeg-dev zlib1g-dev libffi-dev libjpeg62-turbo libtiff5 libopenjp2-7 \
    xz-utils curl ca-certificates fontconfig \
    nodejs npm \
 && rm -rf /var/lib/apt/lists/*

# wkhtmltopdf (recomendado 0.12.6)
RUN curl -L -o /tmp/wkhtml.deb \
    https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bookworm_amd64.deb \
 && apt-get update && apt-get install -y /tmp/wkhtml.deb --no-install-recommends \
 && rm -f /tmp/wkhtml.deb

# Usuário e pastas
RUN useradd -ms /bin/bash odoo \
 && mkdir -p ${ODOO_HOME} ${ODOO_DATA} ${ODOO_EXTRA_ADDONS} /etc/odoo \
 && chown -R odoo:odoo ${ODOO_HOME} ${ODOO_DATA} ${ODOO_EXTRA_ADDONS} /etc/odoo

# Odoo (community) 19.0
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

# Porta HTTP virá do Railway ($PORT)
EXPOSE 8069

# Healthcheck básico
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl -fsS http://127.0.0.1:${PORT:-8069}/web || exit 1

USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash", "-lc", "python ${ODOO_HOME}/src/odoo-bin -c ${ODOO_CONF} --http-port=${PORT:-8069}"]
