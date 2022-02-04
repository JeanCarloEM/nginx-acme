#!/bin/bash

include ./.functions

_DOMINIO=$(getParam $* "-dom")
_USER=$(getParam $* "-user")
_dom_path_=$(getParam $* "-path")

# VALIDADORES DENOME DE USUARIO E NOME DE DOMINIO
REGEXDOM='^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$'
REGEXNUM='^[0-9]+$'
REGEXUSER='^[a-zA-Z_]+[a-zA-Z0-9_]+$'

if [[ -z "$_dom_path_" ]]; then
	_dom_path_=$DOMFOLDER
fi

# VERIFICA SE OS DADOS FORM FORNECIDOS VIA PARAMETROS
# E SE SAO VALIDOS
if [[ ( -z "$_DOMINIO" ) || ( -z "$_USER" ) || ( ! $_DOMINIO =~ $REGEXDOM ) && ( $_USER =~ $REGEXUSER ) ]]; then
	printf "\n\n"
	printf "Ausência de parâmetos ou são inválidos.\n"
	printf "\n\t Necessários 4 (quatro) parâmetros:"
	printf "\n\t\t -dom <dominio> -user <user>"	
	printf "\n\n"
	exit 1
fi

#
# CRIA A PASTA DO DOMINIO
#
if [[ ! -d "$_dom_path_/$_DOMINIO/" ]];
    mkdir -p "$_dom_path_/$_DOMINIO/"
fi

__RWXAcess "$_dom_path_/$_DOMINIO" "rx" "$_USER"

# CRIA OS SUBDIRETORIOS
mkdir -p "$_dom_path_/$_DOMINIO/.subs/www/"
mkdir -p "$_dom_path_/$_DOMINIO/.subs/@/"
mkdir -p "$_dom_path_/$_DOMINIO/.tls/"

# AS CONFIIGURACOES DO USUARIO
ln -sf /home/$_USER/.webconfig $_dom_path_/$_DOMINIO/.webconfig
yes | rm -f /home/$_USER/.webconfig/.webconfig

# DEFINE O ACESSO PADRAO PARA O OS SUBDOMINIOS
__RWXAcess "$_dom_path_/$_DOMINIO/.subs" "rwx" "$_USER"

# CRIANDO CONFIGURACAO OPCIONAL NGINX
touch $_dom_path_/$_DOMINIO/.nginx.conf

# A PAGINA INDEX DEFAULT
if [[ ! -f "$_dom_path_/$_DOMINIO/.subs/www/index.html" ]]; then
	yes | /bin/cp -rf /etc/nginx/template/index.html "$_dom_path_/$_DOMINIO/.subs/www/"
fi

if [[ ! -f "$_dom_path_/$_DOMINIO/.subs/@/index.html" ]]; then
	yes | /bin/cp -rf /etc/nginx/template/index.html "$_dom_path_/$_DOMINIO/.subs/@/"
fi

# CRIAR A CONFIGURAÇÃO DO DOMINIO
if [[ ! -f /etc/nginx/conf.d/$_USER/$_DOMINIO.conf ]]; then
	mkdir -p /etc/nginx/conf.d/$_USER/

	local dpath="$_dom_path_/$_DOMINIO"
	local tlspath="$_dom_path_/$_DOMINIO/.tls"
	local dominio_excap=$(echo "jeancarloem.com" | sed "s/\\./\\\./g")
fi

cat /etc/nginx/template/MODELO.conf | sed "s/##{DOMINIO}/$_DOMINIO_excap/g" >> /etc/nginx/conf.d/$_USER/$_DOMINIO.conf	
cat /etc/nginx/conf.d/$_USER/$_DOMINIO.conf | sed "s/##{DOMINIO_PATH}/$dpath/g" >> /etc/nginx/conf.d/$_USER/$_DOMINIO.conf	
cat /etc/nginx/conf.d/$_USER/$_DOMINIO.conf | sed "s/##{DOMINIO_TLS}/$tlspath/g" >> /etc/nginx/conf.d/$_USER/$_DOMINIO.conf
cat /etc/nginx/conf.d/$_USER/$_DOMINIO.conf | sed "s/##{PROXY}/$PROXYPASS/g" >> /etc/nginx/conf.d/$_USER/$_DOMINIO.conf
cat /etc/nginx/conf.d/$_USER/$_DOMINIO.conf | sed "s/##{PHP}/$PHPASS/g" >> /etc/nginx/conf.d/$_USER/$_DOMINIO.conf

# CRIA A CONFIGURACAO DO USUÁRIO COM INCLUSÃO TOTAL DO SUB FOLDER
if [[ ! -f "/etc/nginx/conf.d/$_USER.conf" ]]; then

	cat <<EOL >> /etc/nginx/conf.d/${_USER}.conf
include /etc/nginx/conf.d/$_USER/*.conf;
EOL

fi