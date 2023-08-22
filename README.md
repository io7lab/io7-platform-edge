# io7 Platform Edge Server

This is the io7 platform edge server repository. 

It is the the Edge Server for the io7 platform(https://github.com/io7lab/io7-platform-cloud) and is built with the io7 gateway capability.

This gateway has the following configuration format.

**Configuration File - config.json**
```
{
    "cloud_mqtt" : "CLOUD_SERVER",

    "local_mqtt" : "mqtt",

    "clientOption" : {
        "username" : "GATEWAY_ID",
        "password" : "GATEWAY_PW",
        "clientId" : "GATEWAY_ID",
        "clean" : false,
        "rejectUnauthorized": true
    }
}
```

# Edge Server Configuration
The Edge server can be configured as follows.
1. If **local_mqtt** and/or **cloud_mqtt** have the protocol, then the gateway will honor them, ie just use them.
2. But if environment variable **NODE_EXTRA_CA_CERTS** or **extra_ca** variable is defined in config.json, then the cloud connection will be adjusted to use TLS, ie mqtts.


   i.e.
```
      {
            "cloud_mqtt" : "iotlab101.io7lab.com",
            "local_mqtt" : "mqtt",
  =====>    "extra_ca" : "io7lab.pem",
            "clientOption" : {
                "username" : "gw1",
                "password" : "gw1",
                "clientId" : "gw1",
                "clean" : false,
                "rejectUnauthorized": true
            } 
        }
```




**Configuration Example without TLS**
```
{
    "cloud_mqtt" : "iotlab101.ddns.net",

    "local_mqtt" : "mqtt",

    "clientOption" : {
        "username" : "gw1",
        "password" : "gw1",
        "clientId" : "gw1",
        "clean" : false,
        "rejectUnauthorized": false
    }
}
```

**Configuration Example with TLS**
```
{
    "cloud_mqtt" : "iotlab101.ddns.net",

    "local_mqtt" : "mqtt",

    "extra_ca" : "io7lab.pem",

    "clientOption" : {
        "username" : "gw1",
        "password" : "gw1",
        "clientId" : "gw1",
        "clean" : false,
        "rejectUnauthorized": false
    }
}
```
3. For the TLS connection to Cloud, the certificate file should be mounted. Take a look at the commented lines in the `docker-compose.yml`
```
   :
   :
  io7edge:
    container_name: io7edge
    image: io7lab/io7-edge
#    environment:
#      - NODE_EXTRA_CA_CERTS=io7lab.pem
    volumes:
#      - ./data/gateway/io7lab.pem:/home/node/app/io7lab.pem       <=== uncomment this line and adjust the certificate file name
      - ./data/gateway/config.json:/home/node/app/config.json
    links:
      - mqtt
    restart: always
```
