#!/bin/bash

usage()
{
    echo "usage: ./installDocker.sh URLGithubRepository"
    echo "example: ./installDocker.sh https://github.com/wuvel/baddy.git"
}

# Slicing nama repo (parameter) untuk mendapatkan nama folder
MYVAR="$1"
NAME=${MYVAR##*/}      

# Slicing nama container jika sudah ada
name=`docker ps -a | awk '{print $NF}'`
sliced=${name##*S}
sliced=${sliced//$'\n'/}

# Update + Upgrade Package
#sudo apt-get update
#sudo apt-get upgrade

# Install Package yang dibutuhkan
# - Docker (Container. Tidak membutuhkan apache2 dan php lagi.)
# - Git 
if [ $(dpkg-query -W -f='${Status}' docker.io 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install docker.io;
else
	echo "[V] Docker package already installed"
fi

if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	sudo apt-get --yes install git;
else
	echo -e "[V] Git package already installed"
fi

# Post-Installation Docker untuk non-root user
if [ $(docker ps -a | grep -c "CONTAINER ID") -eq 1 ];
then
	echo -e "[V] Post-Installation Docker already done"
else
	sudo groupadd docker
	sudo usermod -aG docker ${USER}
	echo -e "\nLogout and login back or run the script again!\n"
	newgrp docker
	exit
fi

# Cek folder clone repo apakah sudah ada, delete jika sudah ada
if [ $(ls | grep -c "${NAME%.*}") -eq 1 ];
then
	echo "[V] Deleting existing ${NAME%.*} folder"
	sudo rm -rf "${NAME%.*}"
fi

# Clone dan pull source code dari repo github
git clone $1 --quiet
success=$?

if [[ $success -eq 0 ]];
then
    echo -e "[V] Repository successfully cloned.\n"
fi

# Ke direktori clone tadi
cd "${NAME%.*}"

# Membuat config Docker
touch Dockerfile
echo -e "FROM php:7.2-apache\nCOPY . /var/www/html/" > Dockerfile

# Build docker image
if [ $(docker images | grep -c "tugasweb") -eq 0 ];
then
	docker build -t tugasweb . -q
else
	echo "Removing existing docker image and container:"
	docker container stop "$sliced" 
	docker container rm "$sliced" -f 
	docker image rm tugasweb -f 
	docker build -t tugasweb . -q 
fi

# Run docker image pada port 80
if [ $(docker container ls | grep -c "tugas") -eq 1 ];
then
	echo "Apache and PHP Already Running via Docker"
	echo "U can access your web server in localhost:80"
	exit
else
	docker run -d -p 80:80 tugasweb
	echo " "
	echo "Apache and PHP Installation Complete."
	echo "U can access your web server in localhost:80"
fi

