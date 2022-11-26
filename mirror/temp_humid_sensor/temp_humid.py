#! /usr/bin/env python3

import Adafruit_DHT
import paho.mqtt.publish
from statistics import median
from w1thermsensor import W1ThermSensor
from time import sleep

dht_pin     = 21
ds18s20_pin = 24
sample_time = 300

temp_topic  = 'home/hall/temperature'
humid_topic = 'home/hall/humidity'
mqtt_broker = '10.0.0.10'
mqtt_port   = 1883


def send_mqtt(topic, message):
    paho.mqtt.publish.single(topic,
                              payload = message,
                              hostname = mqtt_broker,
                              port = mqtt_port,
                              retain = True)


def main(sample_time = 60):
    temp = None
    humid = None
    humid_list = []
    temp_sensor = W1ThermSensor()
    while True:
        temp = round(temp_sensor.get_temperature(),1)
        h, _ = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11,dht_pin)
        humid_list.append(h)
        if len(humid_list) > 7:
            humid_list.pop(0)
        humid = median(humid_list)
        if humid:
            send_mqtt(temp_topic,temp)
        send_mqtt(humid_topic,humid)

        print('temperature: {:>4}, humidity: {:>4}'.format(temp,humid))
        sleep(sample_time)

if __name__ == "__main__":
    main(sample_time)
