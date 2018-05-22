#!/usr/bin/python3

from gpiozero import OutputDevice, MotionSensor
from time import sleep
import paho.mqtt.client as mqtt


pir = MotionSensor(4)
monitor = OutputDevice(17, initial_value=True)

mqtt_server = '192.168.1.10'
client_name = 'hall_monitor'
 
pir_topic = "home/hall/motion_sensor"
mirror_topic = "home/hall/mirror"
mirror_command_topic = "home/hall/mirror/set"
 
client = mqtt.Client(client_name)
client.connect(mqtt_server)

def switch_monitor_on_off(value):

    if monitor.value != value:
        monitor.value = value
        return True
    else:
        return False

def publish_pir_change(value):
    if value: 
        state = 'ON'
    else:
        state = 'OFF'

    client.connect(mqtt_server)
    client.publish(pir_topic, state)
    client.disconnect()

def do_state_change(value):
    switch_monitor_on_off(value)
    publish_pir_change(value)
   

sleep(5)
while True:
    switch_monitor_on_off(True)
    pir.wait_for_no_motion()
    value = False
    print('no motion, switching off')
    do_state_change(value)
    pir.wait_for_motion()
    value = True
    print('motion, switching on')
    do_state_change(value)
    sleep(600)
    
        
