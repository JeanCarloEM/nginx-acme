#!/bin/bash

if [ "$(command -v \"systemctl\")" = "" ]; then 
    if [ "$(command -v \"service\")" = "" ]; then 
        nginx -g "daemon off;"
    else 
        service start nginx
    fi
else 
    systemctl start nginx
fi

/bin/bash "/etc/nginx/acme.service"