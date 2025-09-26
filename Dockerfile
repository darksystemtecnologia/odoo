# Imagem oficial do Odoo 19 (baseada em Debian Bookworm)
FROM odoo:19

# Copiamos nosso arquivo de configuração customizado para ler variáveis do Railway
COPY ./addons/ /var/lib/odoo/addons_path

# Railway define automaticamente a variável $PORT
EXPOSE 8069