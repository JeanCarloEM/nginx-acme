#!/bin/bash

include ./.functions

_DOMINIO=$(getParam $* "-dom")
_USER=$(getParam $* "-user")
_dom_path_=$(getParam $* "-path")

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

local dpath="$_dom_path_/$_DOMINIO"

# CRIA OS SUBDIRETORIOS
for sd in "/" "/.subs/www/" "/.subs/@/" "/.tls/". do
	if [[ ! -d "${dpath}$sd" ]]; then
		mkdir -p "${dpath}$sd"
	fi
done

# CRIA O ARQUIVO DE SUBDOMINIOS
if [[ ! -f "$dpath/.alternativenames" ]]; then
	touch "$dpath/.alternativenames"
fi

# CRIA AQUIVOS DE LOG E ERRO
if [[ ! -f "/var/log/nginx/$_DOMINIO/error.log" ]]; then
	touch "/var/log/nginx/$_DOMINIO/error.log"
fi

if [[ ! -f "/var/log/nginx/$_DOMINIO/error.log" ]]; then
	touch "/var/log/nginx/$_DOMINIO/access.log"
fi

# CRIA LINK SIMBOLISCOS PARA OS AQUIVOS DE LOG E ERROS
if [[ ! -f "$dpath/.nginx.error.log" ]]; then
	ln -s "/var/log/nginx/$_DOMINIO/error.log" "$dpath/.nginx.error.log" 
fi

if [[ ! -f "$dpath/.nginx.access.log" ]]; then
	ln -s "/var/log/nginx/$_DOMINIO/access.log" "$dpath/.nginx.access.log" 
fi

# AS CONFIIGURACOES DO USUARIO
ln -sf /home/$_USER/.webconfig $dpath/.webconfig
yes | rm -f /home/$_USER/.webconfig/.webconfig

# CRIANDO CONFIGURACAO OPCIONAL NGINX
if [[ ! -f "$dpath/.nginx.conf" ]]; then
	touch $dpath/.nginx.conf
fi

# CONFIGURA A PAGINA INDEX DEFAULT www
if [[ ! -f "$dpath/.subs/www/index.html" ]]; then
	yes | /bin/cp -rf /etc/nginx/template/index.html "$dpath/.subs/www/"
fi

# CONFIGURA A PAGINA INDEX DEFAULT @
if [[ ! -f "$dpath/.subs/@/index.html" ]]; then
	yes | /bin/cp -rf /etc/nginx/template/index.html "$dpath/.subs/@/"
fi

# CRIAR A CONFIGURAÇÃO DO DOMINIO
if [[ ! -f /etc/nginx/conf.d/$_USER/$_DOMINIO.conf ]]; then
	if [[ ! -d "/etc/nginx/conf.d/$_USER/" ]]; then
		mkdir -p /etc/nginx/conf.d/$_USER/
	fi
	
	local tlspath="$dpath/.tls"
	local dominio_excap=$(echo "$_DOMINIO" | sed "s/\\./\\\./g")
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