#!/bin/bash
set -ex
#Importamos archivo .env
source .env
#Eliminamos descargas previas
rm -f /tmp/latest.*
#Descargamos el código fuente de wordpress
wget https://wordpress.org/latest.zip -P /tmp
#Descomprimir zip
apt update
apt install unzip -y
rm -rf /tmp/wordpress
unzip /tmp/latest.zip -d /tmp
#Movemos los archivos que hemos descomprimido a /var/www/html
rm -rf /var/www/html/*
mv /tmp/wordpress/* /var/www/html/
#Creamos una base de datos de ejemplo
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME";

#Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'%';";
mysql -u root -e "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD'";
#Le asignamos privilegios de nuestra base de datos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'";