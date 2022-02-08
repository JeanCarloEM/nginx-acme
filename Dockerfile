#FROM bash:latest
FROM securefab/openssl:latest AS OPENSSL
FROM neilpang/acme.sh:latest as ACME
FROM nginx:stable AS NGINX

LABEL maintainer="JeanCarloEM.com"
LABEL version="1.0.0"

COPY    --from=OPENSSL / /
COPY    --from=ACME / /

# COPIAR OS ARQUIVOS DE CONFIGURAÇÃO
COPY    ./src/.acme.renew \        
        ./src/acme.renew \
        ./src/acme.service \
        ./src/.functions \
        ./src/nginx.conf \
        ./src/*.sh \
        /etc/nginx/

ADD     ./src/errpages  /etc/nginx/errpages
ADD     ./src/general   /etc/nginx/general
ADD     ./src/template  /etc/nginx/template

ENV ISDOCKERIMAGE=1
ENV DOMFOLDER="/var/www"

# ON INSTALL
RUN     yes | rm -rf /etc/nginx/conf.d/* && \
        chmod +x /etc/nginx/install.sh && \
        chmod +x /etc/nginx/.acme.renew && \
        chmod +x /etc/nginx/acme.renew && \
        chmod +x /etc/nginx/acme.service && \
        chmod +x /etc/nginx/start.sh && \
        chmod +x /etc/nginx/.acme.renew && \
        (crontab -l 2>/dev/null; echo "*/1     *       *       *       *       /etc/nginx/acme.renew") | crontab - &&  \
        (crontab -l 2>/dev/null; echo "@reboot                                 /etc/nginx/start.sh") | crontab -

run \
    if [ ! command -v "systemctl" &> /dev/null ]; then \
        if [ ! command -v "service" &> /dev/null ] ; then \
            run nginx -g daemon off \
        else \
            run service enable start \
        fi \
    else \
        systemctl enabel nginx  \
    fi

# ON START
ENTRYPOINT /etc/nginx/start.sh

# EXPOR PORTA
EXPOSE 80/tcp
EXPOSE 443/tcp