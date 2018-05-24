#!/usr/bin/python3

from gpiozero import OutputDevice, MotionSensor
from time import sleep
import paho.mqtt.client as mqtt
from time import time, sleep

mirror_cmd_topic   = 'home/hall/mirror/set'
motion_state_topic    = "home/hall/motion_sensor"
mirror_state_topic = "home/hall/mirror"
mqtt_server = '192.168.1.10'
client_name = 'hall_monitor'

#workflow:
#* set-up mqtt
#* set-up monitor


class mqtt_handler:

    def __init__(self, name):
        self._client =  mqtt.Client(name)
        self.connected = False
        self.server = None
        self.topic = None
        self.on_connect = None
              
    def __connect(self):
        try:
            self._client.connect(self.server)
            self._client.subscribe(self.topic)
            self._client.on_message = self.on_connect 
            self.connected = True
        except OSError: 
            self.connected = False
            
    def connect_and_subscribe(self, server, callback, topic):
        self.server = server
        self.topic  = topic
        self.on_connect = callback
        self.__connect()
    
    def send_message(self, topic, message):
        print('sending ', message, ' to ', topic)
        try: 
            self._client.publish(topic, message)
            self.connected = True
        except OSError:
            self.connected = False

    def check_connection(self):
        if not self.connected:
            self.__connect()
        return self.connected     


class magic_mirror:

    def __init__(self, pir_tpc, mirror_tpc, mirror_cmd_tpc, pir_pin = 4, monitor_pin = 17):
  
        self.motionsensor   = MotionSensor(pir_pin)
        self.monitor        = OutputDevice(monitor_pin, initial_value=True)
        self.motion_tpc     = pir_tpc
        self.mirror_tpc     = mirror_tpc
        self.mirror_cmd_tpc = mirror_cmd_tpc
        self.state          = 'ON'
        self.motion         = 'OFF'
        self.last_motion_tm = time()
        
    def __str__(self):
        return 'monitor state: {} motion: {} last motion {}'.format(self.state, self.motion, round(self.last_motion_tm,0))

    def switch_monitor_on_off(self, value):

        if value:
            self.state = 'ON'
        else:
            self.state = 'OFF'
        if self.monitor.value != value:
            self.monitor.value = value
            return True
        else:
            return False

    def toggle_monitor(self):
        self.switch_monitor_on_off(not self.monitor.value)

    def monitor_on(self):
        self.switch_monitor_on_off(True)
        
    def monitor_off(self):
        self.switch_monitor_on_off(False)
        
    def check_motion(self, change_monitor = True, delay = 300):
        if self.motionsensor.motion_detected:
            self.motion = 'ON'
            self.last_motion_tm = time()
        elif (time() - self.last_motion_tm) <  delay:
            self.motion = 'OFF'
        print('last motion', round(self.last_motion_tm), 'since last motion' , round(time() - self.last_motion_tm)) 
        
        if change_monitor:
            self.switch_monitor_on_off(self.motionsensor.value)            

    def on_message(self, client, usrdata, message):
        payload = str(message.payload)
        print('topic', message.topic, 'payload', payload)
        if payload == 'ON':
            self.monitor_on()
        else: 
            self.monitor_off()

def initiate(client_name, mqtt_server, pir_tpc, mirror_tpc, mirror_cmd_tpc):
    mirror = magic_mirror(pir_tpc, mirror_tpc, mirror_cmd_tpc)
    mqtt_client = mqtt_handler(client_name)
    mqtt_client.connect_and_subscribe(mqtt_server, mirror.on_message, mirror.mirror_cmd_tpc)
    return (mirror, mqtt_client)

def run(mirror, mqtt_client):
    while True:
        mqtt_client.check_connection()
        motion_status = mirror.motion
        mirror_status = mirror.state
        mirror.check_motion()
        if motion_status != mirror.motion:
            mqtt_client.send_message(mirror.motion_tpc, mirror.motion)
        if mirror_status != mirror.state:
            print(mirror)
            mqtt_client.send_message(mirror.mirror_tpc, mirror.state)
        sleep(1)
        

        
if __name__ == "__main__":
    mirror, client = initiate(client_name, mqtt_server, motion_state_topic, mirror_state_topic, mirror_cmd_topic)
    run(mirror, client)

