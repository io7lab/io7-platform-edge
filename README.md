This is the io7 platform edge server repository

# Configuration File - config.json
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


# Configuration Example without TLS
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

# Configuration Example with TLS
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
