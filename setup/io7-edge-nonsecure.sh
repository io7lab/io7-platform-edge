#!/bin/bash
#
# This script reverts the currently protected io7 platform back to non-secure mode
# all data are kept intact
dir=$(pwd)/$(dirname $(echo $0))

if [ -z $NODE_PATH ] ; then
    export NODE_PATH=$(dirname $(which node))/../lib/node_modules
fi

echo Processing docker-compose.yml
cp ~/docker-compose.yml ~/docker-compose.yml.ssl
ca=$(grep  'NODE_EXTRA_CA_CERTS' ~/docker-compose.yml|awk -F"=" '{print $2}')
echo $ca
read

node $dir/modify-docker-compose.js ~/docker-compose.yml <<EOF
- services.io7edge.environment: NODE_EXTRA_CA_CERTS=$ca
- services.io7edge.volumes: ./data/gateway/$ca:/home/node/app/$ca
EOF

docker compose -f ~/docker-compose.yml stop io7edge
docker compose -f ~/docker-compose.yml up -d io7edge