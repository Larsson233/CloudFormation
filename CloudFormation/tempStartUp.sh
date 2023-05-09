#!/bin/bash

# Install LAMP
dnf update -y
dnf install -y wget
dnf install -y mariadb105-server
dnf install -y httpd
dnf install -y php-mysqlnd php-fpm php-mysqli php-json php php-devel php-gd
systemctl start mariadb
systemctl enable mariadb
systemctl start httpd
systemctl enable httpd

#mysql -u root -p
#ToDo: Create user and database
# CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'your_strong_password';
# CREATE DATABASE wordpress-db;
# GRANT ALL PRIVILEGES ON wordpress-db.* TO "wordpress-user"@"localhost";
# FLUSH PRIVILEGES;

#ToDo: Secure MariaDB  (mysql_secure_installation)

# Replace with your own values
USER="wordpress-user"
PASSWORD="your_strong_password"
DATABASE="wordpress-db"

# Run SQL statements
mysql -u root <<EOF
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASSWORD';
CREATE DATABASE `$DATABASE`;
GRANT ALL PRIVILEGES ON `$DATABASE`.* TO "$USER"@"localhost";
FLUSH PRIVILEGES;
EOF

#nano /etc/httpd/conf/httpd.conf
#ToDo: AllowOverride All

# Set permissions
chown -R apache /var/www
chgrp -R apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} ;
find /var/www -type f -exec sudo chmod 0644 {} ;

# Install Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
#cp wordpress/wp-config-sample.php wordpress/wp-config.php
#nano wordpress/wp-config.php
#ToDo: Set database name, user and password
# sed -i 's/database_name_here/wordpress-db/g' wordpress/wp-config.php
# sed -i 's/username_here/wordpress-user/g' wordpress/wp-config.php
# sed -i 's/password_here/your_strong_password/g' wordpress/wp-config.php
#ToDo: Salts
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar
chmod +x /tmp/wp-cli.phar 
/tmp/wp-cli.phar config create --dbname=wordpress-db --dbuser=wordpress-user --dbpass=your_strong_password --path=/var/www/html

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
DNS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-hostname)

/tmp/wp-cli.phar core install --url=$DNS --title=Example --admin_user=supervisor --admin_password=strongpassword --admin_email=info@example.com --path=/var/www/html

# wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar
#    45  ls /tmp/
#    46  chmod +x /tmp/wp-cli.phar 
#    47  ls /tmp/
#    48  mv /var/www/html/wp-config.php /var/www/html/wp-config.php.bak
#    49  ls /var/www/html/
#    50  wp config create --dbname=wordpress-db --dbuser=wordpress-user --dbpass=your_strong_password --path=/var/www/html
#    51  /tmp/wp-cli.phar config create --dbname=wordpress-db --dbuser=wordpress-user --dbpass=your_strong_password --path=/var/www/html
#    52  ls /var/www/html/
#    53  cat /var/www/html/wp-config.php
#    54  history