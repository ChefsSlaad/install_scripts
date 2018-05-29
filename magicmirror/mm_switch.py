#!/usr/bin/python3

from gpiozero import OutputDevice, MotionSensor
from time import sleep
import paho.mqtt.client as mqtt
from time import time, sleep

mirror_cmd_topic   = "home/hall/mirror/set"
mirror_state_topic = "home/hall/mirror"
motion_state_topic = "home/hall/motion_sensor"
mqtt_server = '192.168.1.10'
client_name = 'hall_monitor'

#workflow:
#* set-up mqtt
#* set-up monitor


class magic_mirror:

    def __init__(self, pir_tpc, mirror_tpc, mirror_cmd_tpc, pir_pin = 4, monitor_pin = 17):


        self._client =  mqtt.Client('mirror')
        self.connected = False
        self.server = None
        self.topic = None
        self.motionsensor   = MotionSensor(pir_pin)
        self.monitor        = OutputDevice(monitor_pin, initial_value=True)
        self.motion_tpc     = pir_tpc
        self.mirror_tpc     = mirror_tpc
        self.mirror_cmd_tpc = mirror_cmd_tpc
        self.state          = "ON"
        self.autonomous     = True # autonomous: respond to pir or not
        self.motion         = "OFF"
        self.last_motion_tm = time()
        self.last_switched  = time() 
        print('topics: motion: {}, mirror {} mirror_cmd {}'.format(self.motion_tpc, self.mirror_tpc, self.mirror_cmd_tpc))


    def __str__(self):
        states = (self.state, self.motion, self.autonomous, round(time() - self.last_motion_tm), round(time() - self.last_switched))
        return 'monitor state: {} motion: {} auto {}  since last motion {} since last switched {}'.format(*states)

    def __connect(self):
        self._client.connect(self.server)
        self._client.subscribe(self.topic)  
        self._client.on_message = self.on_message
        print('connecting to {} subscribing to {}'.format(self.server, self.topic))
        self.connected = True
        self._client.loop_start()

    def connect_and_subscribe(self, server,  topic):
        self.server = server
        self.topic  = topic
        self.__connect()

    def send_message(self, topic, message):
        print('sending ', message, ' to ', topic)
        self._client.publish(topic, message)
        self.connected = True
        print('message succesfully sent')

    def switch_monitor_on_off(self, value):

        if value:
            self.state = "ON"
        else:
            self.state = "OFF" 
        if self.monitor.value != value:
            self.monitor.value = value
            self.send_message(self.mirror_tpc, self.state)
            return True
        else:
            return False

    def toggle_monitor(self):
        self.switch_monitor_on_off(self.state != 'ON')

    def monitor_on(self):
        self.switch_monitor_on_off(True)
 
    def monitor_off(self):
        self.switch_monitor_on_off(False)

    def check_motion(self, change_monitor = True, delay = 300):
        delay_time = time() - delay
        last_motion  = self.motion
        if self.motionsensor.motion_detected:
            self.motion = 'ON'
            self.last_motion_tm = time()
        elif self.last_motion_tm <  delay_time:
            self.motion = 'OFF'

        if self.last_switched < delay_time:
            self.autonomous = True

        if change_monitor and self.autonomous:
            self.switch_monitor_on_off(self.motion == 'ON')
        if self.motion != last_motion:
            self.send_message(self.motion_tpc, self.motion)

    def on_message(self, client, usrdata, message):
        payload = (message.payload).decode("utf-8")
        print('topic', message.topic, 'payload', payload)
        self.last_switched = time()
        self.autonomous = False
        if payload == 'ON':
            self.monitor_on()
        else: 
            self.monitor_off()


def initiate(client_name, mqtt_server, pir_tpc, mirror_tpc, mirror_cmd_tpc):
    mirror = magic_mirror(pir_tpc, mirror_tpc, mirror_cmd_tpc)
    mirror.connect_and_subscribe(mqtt_server, mirror.mirror_cmd_tpc)
    return (mirror)

def run(mirror):
    print(mirror)
    mirror.check_motion()
    sleep(1)

        
if __name__ == "__main__":
    mirror = initiate(client_name, mqtt_server, motion_state_topic, mirror_state_topic, mirror_cmd_topic)
    while True:
        run(mirror)

