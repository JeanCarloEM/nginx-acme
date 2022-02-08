#!/bin/bash

echo "#######################- Rosetando no start" 

systemctl start nginx && service nginx start && nginx -g daemon off

echo "#######################- Rodando acme" 
/etc/nginx/acme.service