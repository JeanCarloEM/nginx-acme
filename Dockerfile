#FROM bash:latest
FROM nginx:stable AS NGINX
FROM securefab/openssl:latest AS OPENSSL
FROM neilpang/acme.sh:latest as ACME

LABEL maintainer="JeanCarloEM.com"
LABEL version="1.0.0"

ENV ISDOCKERIMAGE=1
ENV DOMFOLDER="/var/www"

COPY --from=OPENSSL / /
COPY --from=NGINX / /

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