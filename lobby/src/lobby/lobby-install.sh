#!/bin/bash

# Copyleft Subin Siby - http://subinsb.com

# http://lobby.subinsb.com/api/lobby/download/latest
download_url="http://lobby.subinsb.com/api/lobby/download/latest"
download_file="/tmp/lobby.zip"

workingDir="$(dirname "$(readlink -f "$0")")/lobby"

# COLORS
red=`tput setaf 1`
green=`tput setaf 2`
NC=`tput sgr0` # No Color

if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit
fi

# Update sources
echo "'apt-get update' should be ran to ensure availability of dependencies."
echo "Make sure you have the 'main' and 'universe' repositories enabled."
echo "Shall I run 'apt-get update' for you (y/n) ?"
read update
if [ $update = "y" ]; then
  apt-get update
fi

# Check if PHP 7 available
phpseven=$(dpkg -s php7.0 2>&1 | grep 'no information')
if [ "$phpseven" == "" ]; then
  echo "Using PHP 7"
  depends=("apache2" "mysql-server" "php7.0-mysql" "php7.0-curl" "php7.0-json" "libapache2-mod-php7.0" "wget" "unzip")
else
  echo "Using PHP 5"
  depends=("apache2" "mysql-server" "php5-mysql" "php5-curl" "php5-json" "libapache2-mod-php5" "wget" "unzip")
fi

for i in "${depends[@]}"
do
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $i|grep "install ok installed")
	if [ "" == "$PKG_OK" ]; then
		echo "The installer needs $i to proceed. Install $i (y/n) ?"
		read install
		if [ $install = "y" ]
			then
			apt-get -f install $i
			apt-get install $i
		else
      echo "${red}Without $i, Lobby can't run. Exiting Installer${NC}"
			exit
		fi
  else
    echo -e "${green}$i is installed${NC}"
	fi
done

echo "All dependencies of Lobby is met. Shall I continue the installation (y/n) ?"
read proceed
if [ $proceed = "n" ]; then
	exit
fi

rm "$workingDir/config.php"
echo "Downloading the latest Lobby version"

wget -d -c -O "$download_file" "$download_url"

echo "Extracting into $workingDir"
unzip -o /tmp/lobby.zip -d "$workingDir"

echo ""
echo "Changing Permissions of Directory"
chown -R root:www-data "$workingDir"
chmod -R ug+rw "$workingDir"
chmod -R o+r "$workingDir"

echo ""
echo "Lobby will be accessible from 'http://lobby.dev'. Do you wish to change the domain ? (y/n)"
read domainPrompt

if [ $domainPrompt = "n" ]; then
  domain="lobby.dev"
else
  echo "Type in the domain. I Recommend 'lobby.dev'"
  read domain
fi
echo "Configuring Lobby to run on domain $domain"
cat > /etc/apache2/sites-available/lobby-$domain.conf << EOF
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	ServerName $domain
	DocumentRoot $workingDir
	<Directory $workingDir/>
		Options Indexes FollowSymLinks
		AllowOverride All
		Order allow,deny
		allow from all
		Require all granted
	</Directory>
	ErrorLog /var/log/apache2/error.log
	LogLevel warn
	CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
echo "127.0.0.1 $domain" >> "/etc/hosts"
a2ensite "lobby-$domain"
service apache2 restart
echo -e "${green}Lobby will be available on http://$domain ${NC}"

echo ""

echo "Enabling rewrite module"
a2enmod rewrite
service apache2 restart

touch /usr/share/lobby/installed.conf
cat > /usr/share/lobby/installed.conf << EOF
http://$domain
EOF

echo -e "${green}Lobby was successfully installed in $workingDir${NC}"
echo "You can now start the installation process from http://$domain Press any key to exit"
read y
