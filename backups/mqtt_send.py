#! /usr/bin/python3


import sys
import paho.mqtt.client as mqtt

def check_args_and_publish():
    arguments = sys.argv
    topic = None
    message = None
    if len(arguments) != 3:
        print('please provide a topic and a message \n', arguments[0], '"topic/name" "message"') 
    elif ( isinstance(arguments[1], str) and isinstance(arguments[2], str)):
        topic = arguments[1]
        message = arguments[2]
        print('publishing', message, 'to topic', topic)
        client.publish(topic, message)

    return topic, message
    


client = mqtt.Client()
client.connect("192.168.1.10")
check_args_and_publish()
