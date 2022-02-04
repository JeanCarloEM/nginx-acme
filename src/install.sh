#!/bin/bash

echo "#######################- Permmisions:   " 


chmod +x /etc/nginx/.acme.renew
chmod +x /etc/nginx/acme.renew
chmod +x /etc/nginx/acme.service
chmod +x /etc/nginx/start.sh


echo "#######################- Run contrab:   " 
                               
(crontab -l 2>/dev/null; echo "*/1     *       *       *       *       /etc/nginx/acme.renew") | crontab - && sleep 1 && /etc/nginx/acme.renew &

crontab -l

echo "#######################- Restarr nginx:   " 

nginx -g 'daemon on'

echo "#######################- finn   " 