#!/bin/bash
#
# This script converts the current io7 edge, so it can connect to secure io7 IOT Platform
#
LINE=$*
myopt() {
    pname=$1
    echo $(echo $LINE | awk -F"-$pname " '{print $2}'|awk -F" " '{print $1}')
}

echo $LINE | grep -e '-h ' -e '-help ' > /dev/null
if [ "$?" -eq 0 ] ; then
    printf "\n\t Usage : \n\n\t\tbash $0 [-ca cafile] [-help /-h ]\n\n"
    printf "-ca cafile : Certificate Authority wihch certified the above Fqully Qualified Domain Name\n"
    exit 1
fi

if [ -z $NODE_PATH ] ; then
    export NODE_PATH=$(dirname $(which node))/../lib/node_modules
fi

ca=$(myopt ca)

if [ "$ca" == "" ] ; then
    printf "Certificate Authority file is required\n"
    exit 2
fi

dir=$(dirname $(echo $0))

echo Processing docker-compose.yml
cp ~/docker-compose.yml ~/docker-compose.yml.nossl
cp $ca ~/data/gateway/$ca

node $dir/modify-docker-compose.js ~/docker-compose.yml <<EOF
services.io7edge.environment: NODE_EXTRA_CA_CERTS=$ca
services.io7edge.volumes: ./data/gateway/$ca:/home/node/app/$ca
EOF

docker compose -f ~/docker-compose.yml stop io7edge
docker compose -f ~/docker-compose.yml up -d io7edge