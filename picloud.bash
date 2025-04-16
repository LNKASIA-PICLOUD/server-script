#!/bin/bash

# Function to show ASCII Art
showMe(){
cat << "EOF"
@@@@@@@@@@@@@@@@@@@@@B?!JJ55#@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@G!^~J!?#@@@@@@@@@@@@@@@@@@@
@@@@@@@&#BBBBBB#&@@@5!7?777J@@@#BBB#BB##&@@@@@@@
@@@@&#BGGGBBPPPGG&@#7?!77!77#@GBPPPBBBGGBB&@@@@@
@&&#BGGGGGBBPPPBB&@YJ??J?J??G@BBGPPBBBGGGGB##&@@
@@#BBGGGGGGBGGG#B&#GGGGGGGGGG&##GGGBGGGGGGBB#@@@
@##BGGGGGGGGBBBB#&B55PPPPPP5G&#BBBBBGGGGGGGB##@@
@@&BGGGGGGGGBBBBBPYPB@@@@@#PYPBBBBBGGGGGGGGB#@@@
@@#BBGGGGGGGGG#BY5PPB@@@@@#PG5YB#BPGGGGGGGBB#@@@
@@&&BBGGGGGGGGGGYGPPB@&P#@#PPG55GGPGGGGGGGB##@@@
@@@&BBGGGGGBGBGBYGPPB@@#&@#PPG5PBBGBGGGGGGB&@@@@
@@@&#BBGGBGBBBB@YPPPB@@&@@#PPGY&#BBBBBGGGG##@@@@
@@@@#BBBBBBB##@@GYGPB@&P#@#PG5P@@##BBBBBBBB@@@@@
@@@&BBBBBB#&@&##&G5PB@@@@@#P5P&&##@&#B#BBBB&@@@@
@@@#BB#B##@@@#5PB&B5P&@@@&GYG&#PPG@@@&#B#B#B@@@@
@@#BB###@@@@@@BPPPGBG5PGP5PBBPPPG@@@@@@&B#B##@@@
@&####&@@@@&BPY5PP5PPBGPGGPP5PP5J5B&@@@@&#####@@
&###@@@@@@@&GJYJY555PYB?G55PP55JYY5#@@@@@@@&##&@
#&@@@@@@@@@@@@BGYJ5J5P5?YP5YYYJGB&@@@@@@@@@@@@#&
@@@@@@@@@@@@@@@@&@BG#BGBGG#GG&&@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOF
}

# Show art and banner
showMe
echo -e "\e[32mThanks for using this script...\e[0m"
sleep 2

# Variables
PICLOUD_DIR="/var/www/picloud"
DB_ROOT_PASS="Lnkasia#2025"
PICLOUD_ADMIN_USER="admin"
PICLOUD_ADMIN_PASS="Lnkasia@2025"
REPO_URL="https://github.com/LnkAsia/picloudserver.git"

# Update packages
apt update && apt install -y \
  apache2 mariadb-server curl unzip gnupg2 php-pear software-properties-common

apt update
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update

apt install -y php7.4 libapache2-mod-php7.4 \
  php7.4-{cli,fpm,common,mbstring,xml,gd,curl,intl,mysql,zip,bcmath}


# Add PHP 7.4 (if not already)
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip}

# Clone ownCloud server repository
rm -rf "$PICLOUD_DIR"
git clone --depth 1 "$REPO_URL" "$PICLOUD_DIR"

# Set permissions
cd "$PICLOUD_DIR"
chown -R www-data:www-data .
chmod -R 755 .

# Apache configuration
cat > /etc/apache2/sites-available/owncloud.conf << EOL
Alias / "/var/www/picloud/"

<Directory /var/www/picloud/>
  Options +FollowSymlinks
  AllowOverride All

  <IfModule mod_dav.c>
    Dav off
  </IfModule>

  SetEnv HOME /var/www/picloud
  SetEnv HTTP_HOME /var/www/picloud
</Directory>
EOL

a2ensite owncloud.conf
a2dissite 000-default.conf
a2enmod rewrite mime unique_id
systemctl restart apache2

# Setup MariaDB
mysql -u root <<EOF
CREATE DATABASE piclouddb;
GRANT ALL PRIVILEGES ON piclouddb.* TO 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

# Run ownCloud installation
sudo -u www-data php $OWNCLOUD_DIR/occ maintenance:install \
  --database "mysql" \
  --database-name "piclouddb" \
  --database-user "admin" \
  --database-pass "${DB_ROOT_PASS}" \
  --admin-user "${OWNCLOUD_ADMIN_USER}" \
  --admin-pass "${OWNCLOUD_ADMIN_PASS}"

echo -e "\e[32mpiCloud successfully installed from latest ZIP!\e[0m"
