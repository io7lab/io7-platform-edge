#!/bin/bash
#
# This script installs and sets the Runtime environment of the HomeOS
#

echo "nodejs will be installed for the link =>"
echo "        https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-arm64.tar.xz"
echo "if you you want to install a different version or the latest if any"
echo "then visit https://nodejs.org/en/download/ and get the link to the nodejs tarball"
echo "paste the link here, otherwise just hit enter"

nodejs_url='https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-arm64.tar.xz'
read url
if [ -z "$url" ]
then
    url=$nodejs_url
fi

fname=$(echo $url|awk -F'/' '{ print $NF }')
rm $fname
wget $url
if [ $? -eq 0 ] 
then
    tar xvf $fname
    cd $(echo $fname|sed 's/.tar.xz$//' | sed 's/.tar.gz$//')
    rm CHANGELOG.md LICENSE README.md
    sudo cp -R * /usr/local
    cd -
    rm -rf $(echo $fname|sed 's/.tar.xz$//' | sed 's/.tar.gz$//')
    sudo npm -g i mqtt basic-auth body-parser cron-parser 
    sudo npm -g i express fs loader node-schedule redis request
else
    echo check the url for the nodejs
fi


curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
id pi 2> /dev/null > /dev/null
if [ $? -eq 0 ] ; then
    sudo usermod -aG docker pi
else
    sudo usermod -aG docker ubuntu
fi
sudo systemctl restart containerd
sudo systemctl restart docker.service docker.socket
sudo apt install docker-compose -y

echo if you are using the serial port device, you need to enable the serial port
