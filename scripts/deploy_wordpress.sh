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
mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'$IP_CLIENTE_MYSQL';";
mysql -u root -e "CREATE USER $DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$DB_PASSWORD'";
#Le asignamos privilegios de nuestra base de datos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'";
#Creamos el archivo deconfiguracion de wordpress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#Configuramos las variables del archivo php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php
#Modificamos los permisos del directorio /var/www/html
chown -R www-data:www-data /var/www/html

# Ahora tendremos que crear un archivo .htaccess en el directorio /var/www/html
cp ../htaccess/.htaccess /var/www/html/

# Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

# Reiniciamos el servicio apache
systemctl restart apache2