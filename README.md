# practica-06-iaw
practica 06
# Modificamos el archivo deploy_wordpress_own_directory.sh
## #!/bin/bash
set -ex

## Los pasos que hay que llevar a cabo para instalar WordPress en su propio directorio
source .env

## Descargamos la última versión de WordPress.
wget http://wordpress.org/latest.zip -P /tmp

## Descomprimimos el archivo .zip que acabamos de descargar.
unzip -u /tmp/latest.zip -d /tmp/

## Eliminamos instalaciones previas de Wordpress en /var/www/html
rm -rf /var/www/html/wordpress/

## Creamos la carpeta Wordpress
mkdir -p /var/www/html/wordpress/

## movemos el contenido de /tmp/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html/wordpress

## Creamos la base de datos y el usuario de la base de datos
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY 'DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@$IP_CLIENTE_MYSQL"

## Renombramos el archivo de configuracion de WordPress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

## Configuramos la variables del archivo de configuracion de WordPress
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/$DB_HOST/" /var/www/html/wordpress/wp-config.php

## Configuramos las variables WP_SITEURL y WP_HOME del archivo de configuración wp-config.php.
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTBOT_DOMAIN/wordpress');" /var/www/html/wordpress/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTBOT_DOMAIN');" /var/www/html/wordpress/wp-config.php

## Copiamos el archivo /var/www/html/wordpress/index.php a /var/www/html.
cp /var/www/html/wordpress/index.php /var/www/html

## Editamos el archivo index.php.
sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/wordpress/index.php 

## Ahora tendremos que crear un archivo .htaccess en el directorio /var/www/html
cp ../htaccess/.htaccess /var/www/html/

## Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

## Reiniciamos el servicio apache
systemctl restart apache2
# Modificamos el archivo deploy_wordpress.sh
## #!/bin/bash
set -ex
## Importamos archivo .env
source .env
## Eliminamos descargas previas
rm -f /tmp/latest.*
## Descargamos el código fuente de wordpress
wget https://wordpress.org/latest.zip -P /tmp
## Descomprimir zip
apt update
apt install unzip -y
rm -rf /tmp/wordpress
unzip /tmp/latest.zip -d /tmp
## Movemos los archivos que hemos descomprimido a /var/www/html
rm -rf /var/www/html/*
mv /tmp/wordpress/* /var/www/html/
## Creamos una base de datos de ejemplo
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME";

## Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'$IP_CLIENTE_MYSQL';";
mysql -u root -e "CREATE USER $DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$DB_PASSWORD'";
## Le asignamos privilegios de nuestra base de datos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'";
## Creamos el archivo deconfiguracion de wordpress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
## Configuramos las variables del archivo php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php
## Modificamos los permisos del directorio /var/www/html
chown -R www-data:www-data /var/www/html

## Ahora tendremos que crear un archivo .htaccess en el directorio /var/www/html
cp ../htaccess/.htaccess /var/www/html/

## Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

## Reiniciamos el servicio apache
systemctl restart apache2