#FROM bash:latest
FROM neilpang/acme.sh:latest
FROM securefab/openssl:latest
FROM nginx:stable

LABEL maintainer="JeanCarloEM.com"
LABEL version="1.0.0"

ENV ISDOCKERIMAGE=1
ENV DOMFOLDER="/var/www"

# COPIAR OS ARQUIVOS DE CONFIGURAÇÃO
COPY ./src/.acme.renew /etc/nginx/
COPY ./src/acme.renew /etc/nginx/
COPY ./src/acme.service /etc/nginx/
COPY ./src/.functions /etc/nginx/
COPY ./src/nginx.conf /etc/nginx/
COPY ./src/*.sh /etc/nginx/

ADD ./src/errpages /etc/nginx/errpages
ADD ./src/general /etc/nginx/general
ADD ./src/template /etc/nginx/template

# ON INSTALL
#RUN chmod +x /etc/nginx/install.sh && /etc/nginx/install.sh

# ON START
ENTRYPOINT chmod +x /etc/nginx/start.sh && /etc/nginx/start.sh

# EXPOR PORTA
EXPOSE 80/tcp
EXPOSE 443/tcp