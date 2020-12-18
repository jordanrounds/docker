# Insteon MQTT Docker Container
This project is for the setup of a Insteon MQTT container using docker-compose. It uses the local-persist plugin to configure the volumes. It will create a duplicate of the default config named insteon_mqtt.yaml and name it insteon_mqtt.yaml.default.

## Getting Started
The USB device to connect to as the modem or hub can be set by modifying the DEVICE variable in the .env file.

[Quick Start Guide](https://github.com/TD22057/insteon-mqtt/blob/master/docs/quick_start.md)

The config/insteon_mqtt.yaml file will then need to be modified.

- Set the Insteon port to be the USB port or address of the PLM modem.
- Set the modem Insteon hex address (printed on the back of the modem).
- Edit the Insteon device section and enter the hex addresses of all the devices you have.
- Edit the storage location. Each device will save it's database in this directory.
- Edit the MQTT topics and payload section. The sample insteon_mqtt.yaml file is designed for integration with Home Assistant but you can change it to use whatever style of messages you want.

[MQTT Guide](https://github.com/TD22057/insteon-mqtt/blob/master/docs/mqtt.md)

The init.sh script create a .env file to store DEVICE, be sure to populate it with the proper path to your Insteon PLM.

## Prerequisits
**Environment Variables**
- DEVICE is the path to the usb connected Insteon PLM
- LOCAL_PERSIST is the root of where data is persisted
- TZ is the timezone

**Local Persist Volume Plugin**

Install the [Local Persist](https://github.com/MatchbookLab/local-persist) volume plugin

```
curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
```

## Installing
Execute setup.sh which will bring the container up and create a link to the persist data.

**Alternatively**

```
docker-compose up --force-recreate --build -d
docker image prune -f
```

## Device Onboarding
There is insteon-mqtt.sh which is a simple script for running the join, pair, and refresh commands.

```
Insteon MQTT Management

What would you like to do?
-------------------------------------
1) Join Device
2) Pair Device
3) Refresh All Devices
4) Refresh Device
-------------------------------------
Choose option: 1

Joining Device
-------------------------------------
Device Address (aa.bb.cc): 
```

## Reference / Acknowledgments
- [Insteon MQTT](https://github.com/TD22057/insteon-mqtt)
- [Docker Image](https://github.com/larizzo/docker-insteon-mqtt)
- [Insteon Command Tables](http://cache.insteon.com/pdf/INSTEON_Command_Tables_20070925a.pdf)
- [Dimmer Ramp Rates](http://www.madreporite.com/insteon/ramprate.htm)
- [Hex Converter](https://www.binaryhexconverter.com/decimal-to-hex-converter)