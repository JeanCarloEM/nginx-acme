# Nginx-Acme

![License](https://badgen.net/github/license/jeancarloem/nginx-acme)  ![latest](https://badgen.net/github/release/jeancarloem/nginx-acme) ![releases](https://badgen.net/github/releases/jeancarloem/nginx-acme) 

![](https://badgen.net/docker/pulls/jeancarloem/nginx-acme?icon=docker) ![](https://badgen.net/docker/size/jeancarloem/nginx-acme/latest?icon=docker&label=size) ![](https://badgen.net/docker/layers/jeancarloem/nginx-acme/latest?icon=docker&label=layers)

Nginx Acme is a docker image of nginx with [Acme.sh](https://github.com/acmesh-official/acme.sh), openssl with optional settings added.

You can access it on [![](https://badgen.net/badge/icon/github?icon=github&label)](https://github.com/JeanCarloEM/nginx-acme) and also on [![](https://badgen.net/badge/icon/docker?icon=docker&label)](https://hub.docker.com/repository/docker/jeancarloem/nginx-acme).

* [Features](#features)
* [Volume Recommendation:](#volume-recommendation)
  * [Directory Structure](#directory-structure)
* [Build](#build)
* [Usage](#usage)

## Features

- Original, unaltered and stable applications;
- [Acme.sh](https://github.com/acmesh-official/acme.sh) is a neat shell for automating TLS certificates with [Let's Encript](https://letsencrypt.org/)..
- Acme for cloudflare;
- Openssl included;
- Optional configuration files, in the ``/etc/nginx/general`` folder.

## Volume Recommendation

These are the folders that must be mounted on volumes for adding configuration.

- ``/etc/nginx/conf.d``
- ``/var/www``

### Directory Structure

There are two masses included in ``/etc/nginx`` that have templates and scripts for adding a new domain (``createdomain.sh``), as well as a shell loop executed at startup (``acme.service``), which automates the creation of any domain's certificate by simply adding a folder with the full name in ``/var/www/``

- ``/etc/nginx/template/``
- ``/etc/nginx/general/``
- ``/etc/nginx/createdomain.sh``
- ``/etc/nginx/acme.service``
- ``/etc/nginx/acme.renew``
- ``/etc/nginx/conf.d/<USERNAME>/<DOMAIN>.conf``

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

## Build

````
$env:DOCKER_BUILDKIT=0
docker build -t jeancarloem/nginx-acme:latest .
````

# Usage

Proxy usage:

````
$env:DOCKER_BUILDKIT=0
docker run  --name nginx-main \
            -v /etc/nginx/conf.d/:/etc/nginx/conf.d/ \
            -v /var/www:/var/www \
            -d -p 80:80 -p 443:443 \
            -e PROXYPASS=<ip-or-socker> \
            -e CF_Token=<you-token> \
            -e CF_Account_ID=<you-account-id> \
            jeancarloem/nginx-acme:latest
````

PHP socket susage:

````
$env:DOCKER_BUILDKIT=0
docker run  --name nginx-main \
            -v /etc/nginx/conf.d/:/etc/nginx/conf.d/ \
            -v /var/www:/var/www \
            -d -p 80:80 -p 443:443 \
            -e PHPASS=<ip-or-socker> \
            -e CF_Token=<you-token> \
            -e CF_Account_ID=<you-account-id> \
            jeancarloem/nginx-acme:latest
````

For test add ``-e USETEST=test``