#!/bin/bash

echo "#######################- Rosando no start" 

systemctl restart nginx || service nginx restart

echo "#######################- Rodando acme" 
. /etc/nginx/acme.service