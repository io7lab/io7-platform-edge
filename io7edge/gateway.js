//
// This gateway has the following characteristics
// 1. if cfg.{local_mqtt, cloud_mqtt} have the protocol, then honor them, ie just use them.
// 2. if environment variable 'NODE_EXTRA_CA_CERTS' or extra_ca variable in config.json is defined,
//    then the cloud connection will be adjusted to use TLS.
//      {
//            "cloud_mqtt" : "iotlab101.io7lab.com",
//            "local_mqtt" : "mqtt",
//  =====>    "extra_ca" : "io7lab.pem",
//            "clientOption" : {
//                "username" : "gw1",
//                "password" : "gw1",
//                "clientId" : "gw1",
//                "clean" : false,
//                "rejectUnauthorized": true
//            } 
//        }
//
const mqtt = require('mqtt');
const fs = require('fs');

const configFile = fs.readFileSync('./config.json', 'utf8');
const cfg = JSON.parse(configFile);
const clientOption = cfg.clientOption;
const gatewayId = cfg.clientOption.username;

clientOption.will = {
    topic: `iot3/${gatewayId}/evt/connection/fmt/json`,
    payload: '{"d":{"status":"offline"}}',
    qos : 0,
    retain: true
}

let local_mqtt = cfg.local_mqtt;
let cloud_mqtt = cfg.cloud_mqtt;

if (!(cfg.local_mqtt.match(/[mqts]*:\/\//))) {
    local_mqtt = 'mqtt://' + cfg.local_mqtt;
}
if (!(cfg.cloud_mqtt.match(/[mqts]*:\/\//))) {
    cloud_mqtt = 'mqtt://' + cfg.cloud_mqtt;
}

if ((cfg.extra_ca !== undefined && fs.existsSync(cfg.extra_ca)) ||
            process.env.NODE_EXTRA_CA_CERTS !== undefined ) {

    cloud_mqtt = 'mqtts://' + cfg.cloud_mqtt.replace(/[mqts]*:\/\//,'');

    if (process.env.NODE_EXTRA_CA_CERTS === undefined) {
        clientOption.ca = [fs.readFileSync('io7lab.pem')];
    }
}

const cloud  = mqtt.connect(cloud_mqtt, clientOption);
const bridge  = mqtt.connect(local_mqtt);

let edgeDevices = [];

let sub4cloud = (device) => {
    console.log('subscribing for ' + device);
    cloud.subscribe(`iot3/${device}/cmd/+/fmt/+`);
    cloud.subscribe(`iot3/${device}/mgmt/initiate/device/reboot`);
    cloud.subscribe(`iot3/${device}/mgmt/device/update`);
    cloud.subscribe(`iot3/${device}/mgmt/device/update`);
    cloud.subscribe(`iot3/${device}/mgmt/initiate/device/factory_reset`);
    cloud.subscribe(`iot3/${device}/mgmt/initiate/firmware/update`);
}

cloud.on('connect', () => {
    cloud.subscribe(`iot3/${gatewayId}/gateway/list`);
    cloud.publish(`iot3/${gatewayId}/evt/connection/fmt/json`, '{"d":{"status":"online"}}', {retain:true});
    cloud.publish(`iot3/${gatewayId}/gateway/query`, '{"d":{"devices":"*"}}');
});

setTimeout(() => {
    bridge.on('connect', () => {
        bridge.subscribe(`iot3/+/evt/+/fmt/+`);
        bridge.subscribe(`iot3/+/mgmt/device/meta`);
    });
}, 2);

cloud.on('message', (topic, message) => {
    if ( topic === `iot3/${gatewayId}/gateway/list` ) {
        const list = JSON.parse(message.toString());

        edgeDevices = [];
        list.forEach(d => {
            edgeDevices.push(d);
            sub4cloud(d);
        })
    } else {
        bridge.publish(topic, message.toString());
    }
});

bridge.on('message', (topic, message) => {
    const topic_ = topic.split('/');
    if (edgeDevices.includes(topic_[1])) {
        if (topic_[3] !== 'connection') {
            if (topic_[4] === 'meta') {
                cloud.publish(topic, message.toString(), { retain: true });
            } else {
                cloud.publish(topic, message.toString());
            }
        }
    } else {
        if (topic_[3] !== 'connection' && topic_[4] !== 'meta') {
        // skipping all the retained messages
            cloud.publish(`iot3/${gatewayId}/gateway/add`, `{"d":{"devId":"${topic_[1]}"}}`);
        }
    }
});
