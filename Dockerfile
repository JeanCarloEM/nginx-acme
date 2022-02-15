#FROM bash:latest
#FROM securefab/openssl:latest AS OPENSSL
FROM neilpang/acme.sh:latest as ACME
FROM nginx:stable AS NGINX

LABEL maintainer="JeanCarloEM.com"
LABEL version="1.0.0"

#COPY    --from=OPENSSL / /
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
RUN apk update && \
    apk add --no-cach curl openrc socat nano gzip busybox-initscripts logrotate && \
    apk del openssl && apk add openssl3 && ln -s /usr/bin/openssl3 /usr/bin/openssl && \
    echo "/var/log/*.log /var/log/*/*.log /var/log/*/*/*.log {\
        daily\
        rotate 14\
        size 5k\
        dateext\
        dateformat -%Y-%m-%d\
        missingok\
        compress\
        delaycompress\
        sharedscripts\
        notifempty\
        postrotate\
            test -r /var/run/nginx.pid && kill -USR1 `cat /var/run/nginx.pid`\
        endscript\
    }" > /etc/logrotate.d/nginx && \
    yes | rm -rf /etc/nginx/conf.d/* && \    
    chmod +x /etc/nginx/.acme.renew && \
    chmod +x /etc/nginx/acme.renew && \
    chmod +x /etc/nginx/acme.service && \    
    chmod +x /etc/nginx/.acme.renew && \
    chmod +x /etc/nginx/start.sh && \
    (crontab -l 2>/dev/null; echo "* * * * * /etc/nginx/acme.service") | crontab - && \    
    (crontab -l 2>/dev/null; echo "@reboot   nginx -g 'daemon off;'") | crontab - && \
    crond

# ON START
ENTRYPOINT  ["/etc/nginx/start.sh"]

# EXPOR PORTA
EXPOSE 80/tcp
EXPOSE 443/tcp