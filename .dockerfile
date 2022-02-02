FROM bash:latest
FROM neilpang/acme.sh:latest
FROM securefab/openssl:latest
FROM nginx:stable

LABEL maintainer="JeanCarloEM.com"
LABEL version="1.0.0"

ENV ISDOCKERIMAGE=1
ENV DOMFOLDER="/var/www"

# COPIAR OS ARQUIVOS DE CONFIGURAÇÃO
COPY ./src/* /etc/nginx/

# ON INSTALL
RUN chmod +x /etc/nginx/install.sh && /etc/nginx/install.sh

# ON START
ENTRYPOINT chmod +x /etc/nginx/start.sh && /etc/nginx/start.sh

# EXPOR PORTA
EXPOSE 80/tcp
EXPOSE 443/tcp