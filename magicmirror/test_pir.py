#!/usr/bin/python3

from gpiozero import OutputDevice, MotionSensor
from time import sleep
import paho.mqtt.client as mqtt


pir_topic = "home/hall/motion_sensor"
mirror_topic = "home/hall/mirror"
mirror_command_topic = "home/hall/mirror/set"


#workflow:
#* set-up mqtt
#* set-up monitor


class mqtt_handler(mqtt):
    def connect_and_subscribe(client_name, server, callback, topics):
        pass
    
    def send_message(topic, message):
        pass

mqtt_server = '192.168.1.10'
client_name = 'hall_monitor'
 
 
client = mqtt.Client(client_name)
client.connect(mqtt_server)

    def publish_pir_change(value):
        if value: 
            state = 'ON'
        else:
            state = 'OFF'

    client.connect(mqtt_server)
    client.publish(pir_topic, state)
    client.disconnect()


class magic_mirror:

    def __init__(self, pir_tpc, mirror_tpc, mirror_cmd_tpc, pir_pin = 4, monitor_pin = 17):
  
        self.motionsensor   = MotionSensor(pir_pin)
        self.monitor        = OutputDevice(monitor_pin, initial_value=True)
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

