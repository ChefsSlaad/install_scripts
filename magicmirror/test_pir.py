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

mqqt_client = None
monitor = None

#workflow:
#* set-up mqtt
#* set-up monitor


class mqtt_handler(mqtt):

    def __init__(self, client_name):
        super().__init__(client_name)
        self.connected = False
        self.server = None
        self.topic = None
              
    def __connect(self):
        try:
            self.connect(self, self.server)
            self.subscribe(self.topic)
            self.connected = True
        except OSError:
            self.connected = False
            
    def connect_and_subscribe(self, server, callback, topic):
        self.server = server
        self.topic  = topic
        self.on_connect = callback
        self.__connect()
    
    def send_message(self, topic, message):
        try: 
            self.publish(topic, state)
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
        return 'monitor state: {} motion: {} last motion {}'.format(self.state, self.monitor, self.last_motion_tm)

    def switch_monitor_on_off(value):

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
        self.switch_monitor_on_off(!self.monitor.value)

    def monitor_on(self):
        self.switch_monitor_on_off(True)
        
    def monitor_off(self):
        self.switch_monitor_on_off(False)
        
    def check_motion(self, change_monitor = True, delay = 300):
        if self.motionsensor.motion_detected:
            self.motion = 'ON'
            self.last_motion_tm = time()
        elif (self.last_motion_tm + delay) < time():
            self.motion = 'OFF'
        
        if change_monitor:
            self.switch_monitor_on_off(self.motionsensor.value)            

    def on_message(self, client, usrdata, message):
        print('topic', message.topic, 'payload', message.payload)
        

def initiate(client_name,mqtt_server, pir_tpc, mirror_tpc, mirror_cmd_tpc):
    mirror = magicmirror(pir_tpc, mirror_tpc, mirror_cmd_tpc)
    client = mqtt.Client(client_name)
    client.connect_and_subscribe(mqtt_server, mirror.on_motion, mirror.mirror_cmd_tpc)

def run():
    while True:
        client.check_connection()
        motion_status = mirror.motion
        mirror_status = mirror.state
        mirror.check_motion()
        if motion_status != motion.state:
            client.publish(mirror.motion_tpc, mirror.motion)
        if mirror_status != mirror.state:
            client.publish(mirror.mirror_tpc, mirror.state)
        sleep(1)
        

        
if __name__ == "__main__":
    initiate(client_name, mqtt_server, motion_state_topic, mirror_state_topic, mirror_cmd_topic)
    run()

