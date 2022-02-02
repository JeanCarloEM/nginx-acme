# Nginx-Acme

![Build Status](https://badgen.net/badge/build/testing/red?icon=github)

Nginx Acme é um projeto de imagem docker que integra nginx, [Acme.sh](https://github.com/acmesh-official/acme.sh) e openssl, com acréscimo de configuações opicionais.

- Original and unaltered applications;
- [Acme.sh](https://github.com/acmesh-official/acme.sh) is a neat shell for automating TLS certificates with [Let's Encript](https://letsencrypt.org/)..

## Features

- Acme for cloudflare;
- Openssl included;
- Optional configuration files, in the ``/etc/nginx/general`` folder.

## Directories to mount as volume:
- ``/etc/nginx/conf.d``
- ``/var/www``

### Directory Structure

There are two masses included in ``/etc/nginx`` that have templates and scripts for adding a new domain (``createdomain.sh``), as well as a shell loop executed at startup (``acme.service``), which automates the creation of any domain's certificate by simply adding a folder with the full name in ``/var/www/``

- ``/etc/nginx/template/``
- ``/etc/nginx/general/``
- ``/etc/nginx/createdomain.sh``
- ``/etc/nginx/acme.service``
- ``/etc/nginx/acme.renew``

The ``createdomain.sh`` needs 4 parameters, as follows:
> ``./createdomain.sh -dom <example.com> -user <linuxuser>``

Already ``acme.renew`` that executes acme\.sh, needs to be executed according to the syntax:
> ``./acme.renew -dom "<example.com>" -path "/var/www/<dominio>" -tipo "ECDSA" -cfkey "<CLOUDFLARE_KEY>" -cfmail "<CLOUDFLARE_MAIL>"``

The location and construction of the structure of each domain and subdomain follows the following structure:

- ``/var/www/<dominio>/.subs/@/``
- ``/var/www/<dominio>/.subs/www/``
- ``/var/www/<dominio>/.subs/<another-subdomínio>/``
- ``/var/www/<dominio>/.tls/``
- ``/var/www/<dominio>/.nginx.conf``
- ``/var/www/<dominio>/.alternativenames``
- ``/var/www/<dominio>/.php_fpm.pool.conf``
- ``/var/www/<dominio>/.nginx.error.log``
- ``/var/www/<dominio>/.nginx.access.log``

The ``www`` and ``@`` ``<subdomain>`` are installed by default. The latter being the equivalent of the domain without ``www``, such as "example.com". Adding a new subdomain is easily accomplished by adding a folder with the subdomain name inside ``/var/www/<domain>/.subs/``.

The ``.nginx.conf`` file is where you can add additional settings.

The ``.alternativenames`` is a text file where each subdomain to be included in the certificate must be added separated by lines. Note, however, that the certificate is already requested with a wildcard *.example.com, that is, it is only necessary to add the second level subdomains such as ``idp.account`` or ``galery.profile``.

## License

MIT
