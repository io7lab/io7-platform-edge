#!/bin/bash
#
# This script installs the docker container images for the io7 edge server
# It should run after making sure the Docker engine is running
sedOpt=
if [ $(uname) = 'Darwin' ]
then
    sedOpt=".bak"
fi
if [ -z $NODE_PATH ] ; then
    export NODE_PATH=$(dirname $(which node))/../lib/node_modules
fi

echo io7 Gateway setup
echo Enter the MQTT Cloud Address &&read cloud_server
echo Enter the gateway id && read client_id
echo Enter the gateway password && read client_pw

dir=$(dirname $(echo $0))

echo Processing docker-compose.yml
cp $dir/../docker-compose.yml ~
cp -R $dir/../data ~/

node $dir/modify-docker-compose.js ~/docker-compose.yml <<EOF
services.io7edge.command: [ "node", "gateway.js" ]
services.io7edge.volumes: ./data/gateway:/home/node/app
EOF

cd ~/data/nodered
npm i

sed -i $sedOpt "s/CLOUD_SERVER/$cloud_server/" ~/data/gateway/config.json
sed -i $sedOpt "s/GATEWAY_ID/$client_id/" ~/data/gateway/config.json
sed -i $sedOpt "s/GATEWAY_PW/$client_pw/" ~/data/gateway/config.json

cd ~
docker-compose up -d
