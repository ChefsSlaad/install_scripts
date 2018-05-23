#!/usr/bin/python3

from gpiozero import OutputDevice, MotionSensor
from time import sleep
import paho.mqtt.client as mqtt

mirror_cmd_topic   = 'home/hall/mirror/set'
pir_state_topic    = "home/hall/motion_sensor"
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
        self.callback = None
        self.topics = []
              
    def __connect(self):
        pass


    def connect_and_subscribe(self, server, callback, topics):
        pass
    
    def send_message(self, topic, message):
        try 
            self.publish(topic, state)
        except OSError
            self.connected = False

 
 
    def publish_pir_change(value):
        if value: 
            state = 'ON'
        else:
            state = 'OFF'

    client.connect(mqtt_server)
    client.publish(pir_state_topic, state)
    client.disconnect()


class magic_mirror:

    def __init__(self, pir_tpc, mirror_tpc, mirror_cmd_tpc, pir_pin = 4, monitor_pin = 17):
  
        self.motionsensor   = MotionSensor(pir_pin)
        self.monitor        = OutputDevice(monitor_pin, initial_value=True)
        self.pir_tpc        = pir_tpc
        self.mirror_tpc     = mirror_tpc
        self.mirror_cmd_tpc = mirror_cmd_tpc
        self.state          = 'ON'
        self.motion         = 'OFF'
        
    def __str__(self):
        return 'monitor state: {}    motion: {}'.format(self.state, self.monitor)

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
        
    def check_motion(self, change_monitor = False):
        if self.motionsensor.motion_detected:
            self.motion = 'ON'
        else:
            self.motion = 'OFF'
        
        if change_monitor:
            self.switch_monitor_on_off(self.motionsensor.value)            

    def on_message(self, client, usrdata, message):
        print(message.topic)
        print(message.payload)
        

def initiate(client_name,mqtt_server, callback, pir_tpc, mirror_tpc, mirror_cmd_tpc):
    mirror = magicmirror(pir_tpc, mirror_tpc, mirror_cmd_tpc)
    client = mqtt.Client(client_name)
    client.connect_and_subscribe(mqtt_server, callback, mirror.mirror_cmd_tpc)

def run():
    while True:
        
        

        
if __name__ == "__main__":


    sleep(5)
    while True:
        switch_monitor_on_off(True)
        try:
            pir.wait_for_no_motion()
            value = False
            do_state_change(value)
            pir.wait_for_motion()
            value = True
            do_state_change(value)
            sleep(600)
        except:
            pass

