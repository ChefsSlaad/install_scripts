#! /usr/bin/env python3

import gpiozero
import paho.mqtt.publish
import paho.mqtt.client
import os
from time import time, sleep

class motion_mirror:

    def __init__(self,
                 motion_pin         = 27,
                 monitor_pin        = 22, # was 17
                 motion_topic       = 'home/hall/motion_sensor',
                 monitor_topic      = 'home/hall/mirror',
                 monitor_set_topic  = 'home/hall/mirror/set',
                 monitor_refresh    = 'home/hall/mirror/refresh',
                 monitor_reboot     = 'home/hall/mirror/reboot',
                 mqtt_broker        = '10.0.0.10',
                 refresh_script     = '/home/pi/kiosk/refresh.sh',
                 reboot_script      = 'sudo /home/pi/kiosk/reboot.sh',
                 mqtt_port          = 1883
                ):

        self.motion_topic = motion_topic
        self.monitor_topic = monitor_topic
        self.monitor_set_topic = monitor_set_topic
        self.monitor_refresh_topic = monitor_refresh
        self.monitor_reboot_topic = monitor_reboot

        self.monitor = gpiozero.DigitalOutputDevice(monitor_pin,
                                                    initial_value=True)

        self.motion_sensor = gpiozero.DigitalInputDevice(motion_pin,
                                                bounce_time = 5,
                                                pull_up = False)

        self.mqtt_client = paho.mqtt.client.Client('motion_mirror')
        self.mqtt_client.on_message = self.on_mqtt
        self.mqtt_client.connect(mqtt_broker, mqtt_port)
        self.mqtt_client.subscribe(monitor_set_topic)
        self.mqtt_client.subscribe(monitor_refresh)
        self.mqtt_client.subscribe(monitor_reboot)
        self.refresh_script = refresh_script
        self.reboot_script = reboot_script
        self.main_loop()

    def monitor_change(self, state):
        if state == 'ON':
            self.monitor.on()
        elif state == 'OFF':
            self.monitor.off()
        self.send_mqtt(self.monitor_topic, state)

    def motion_change(self, state):
        self.send_mqtt(self.motion_topic, state)

    def monitor_reboot(self):
        os.system(self.reboot_script)

    def monitor_refresh(self):
#        print('refreshing kiosk')
        os.system(self.refresh_script)

    def main_loop(self):
        old_motion = None
        change_time = time()
        while True:
            if self.motion_sensor.is_active != old_motion:
                if self.motion_sensor.is_active:
                    self.send_mqtt(self.motion_topic, 'ON')
                else:
                    self.send_mqtt(self.motion_topic, 'OFF')
                old_motion = self.motion_sensor.is_active
            self.mqtt_client.loop(.1)

    def on_mqtt(self, client, usrdata, message):
        topic = message.topic
        print('recieved', topic, message.payload)
        if topic == self.monitor_set_topic:
            message = message.payload.decode('utf-8')
            self.monitor_change(message)
        elif topic == self.monitor_refresh_topic:
            self.monitor_refresh()
        elif topic == self.monitor_reboot_topic:
            self.monitor_reboot()

    def send_mqtt(self, topic, message):
        self.mqtt_client.publish(topic,
                                 payload = message,
                                 retain = True)
        print('sending', topic, message)


if __name__ == "__main__":
    monitor = motion_mirror()
