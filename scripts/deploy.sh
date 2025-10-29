#!/bin/bash
set -ex
#Importamos el archivo .env
source .env
#Eliminamos las descargas previas del repositorio
rm -rf /tmp/iaw-practica-lamp
#Clonamos el repositorio con el código de la aplicación web
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp
#Movemos el código fuente de la aplicación a /var/www/html
mv /tmp/iaw-practica-lamp/src/* /var/www/html/
#Creamos una base de datos, un usuario y una contraseña
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME"
mysql -u root -e "DROP USER IF EXISTS $DB_USER@'%'"
mysql -u root -e "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD'"
#Le asignamos privilegios al usuario
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'"
#Modificamos el archivo de configuración config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php
#Ejecutamos el script de creación de tablas
mysql -u root $DB_NAME < /tmp/iaw-practica-lamp/db/database.sql