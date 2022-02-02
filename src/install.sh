#!/bin/bash

chmod +x /etc/nginx/.acme.renew
chmod +x /etc/nginx/acme.renew
chmod +x /etc/nginx/acme.service
chmod +x /etc/nginx/start.sh

systemctl enable nginx