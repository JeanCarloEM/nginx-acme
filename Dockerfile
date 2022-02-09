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
RUN yes | rm -rf /etc/nginx/conf.d/* && \    
    chmod +x /etc/nginx/.acme.renew && \
    chmod +x /etc/nginx/acme.renew && \
    chmod +x /etc/nginx/acme.service && \
    chmod +x /etc/nginx/entrypoint.sh && \
    chmod +x /etc/nginx/.acme.renew && \
    (crontab -l 2>/dev/null; echo "* * * * * /bin/bash '/etc/nginx/acme.service'") | crontab - &&  \
    (crontab -l 2>/dev/null; echo "@reboot     /etc/nginx/start.sh") | crontab - && \
    (crontab -l 2>/dev/null; echo "@reboot     nginx -g 'daemon off;'") | crontab -

# ON START
ENTRYPOINT ["/etc/nginx/entrypoint.sh"]

# EXPOR PORTA
EXPOSE 80/tcp
EXPOSE 443/tcp