#!/bin/bash

usage()
{
    echo "usage: ./installManual.sh URLGithubRepository"
    echo "example: ./installManual.sh https://github.com/wuvel/baddy.git"
}

# Slicing nama repo (parameter) untuk mendapatkan nama folder
MYVAR="1"
NAME=${MYVAR##*/}      


# Update + Upgrade Package
sudo apt-get update
sudo apt-get upgrade


# Install Package yang dibutuhkan
# - Apache2
# - PHP
# - Git 
if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install apache2;
else
	echo "[V] apache2 package is installed."
fi

if [ $(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install php;
else
	echo -e "[V] php package is installed."
fi

if [ $(dpkg-query -W -f='${Status}' libapache2-mod-php 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install libapache2-mod-php;
else
	echo -e "[V] libapache2-mod-php package is installed"
fi

if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install git;
else
	echo -e "[V] git package is installed"
fi

# Cek status apache2 dan start
if [ $(sudo systemctl status apache2 | grep -c "active (running)") -eq 1 ];
then
	echo "[V] Apache2 run successfully."
else
	echo "[V] Restarting apache2."
	sudo systemctl restart apache2
	if [ $(sudo systemctl status apache2 | grep -c "active (running)") -eq 0 ];
	then
		echo "Apache2 does not work after restarting the service."
		echo "Exiting program..."
		exit
	fi
fi


# Cek folder clone repo apakah sudah ada, delete jika sudah ada
if [ $(ls | grep -c "${NAME%.*}") -eq 1 ];
then
	echo "[V] Deleting existing ${NAME%.*} folder"
	sudo rm -rf "${NAME%.*}"
fi


# Clone dan pull source code dari repo github
git clone https://github.com/wuvel/simple-php.git --quiet
success=$?

if [[ $success -eq 0 ]];
then
    echo -e "[V] Successfully cloned the repository."
fi


# Memindahkan hasil clone ke direktori /var/www/html 
echo -e "[V] Moving the clone folder to a /var/www/html\n\n"
sudo rm /var/www/html/index.*
cd "${NAME%.*}"
sudo mv * /var/www/html/	

# Sukses
echo "Apache2 and PHP Installation Complete."
echo "You can access your web server on port 80"
