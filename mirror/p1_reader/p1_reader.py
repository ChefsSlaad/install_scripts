#! /usr/bin/env python3

import paho.mqtt.client as mqtt
from converter import read_datagram
from serial_reader import read_telegram
from time import sleep, time
from json import dumps

power_topic = 'home/power_meter'
mqtt_server = '10.0.0.10'
client_name = 'power_meter'
refresh_int = 60

def main():
    secs = time()
    mqtt_client = mqtt.Client()
    mqtt_client.connect(mqtt_server, 1883)
    max_time = refresh_int
    datagram = read_datagram(next(read_telegram()))
    gas      = datagram['gas_delivered']
    gas_old  = gas
    gas_time = datagram['gas_read_time']
    gas_time_old = gas_time
    pwr      = datagram['tarif_1_delivered'] + datagram['tarif_2_delivered']
    pwr_old  = pwr
    pwr_time = datagram['date_time']
    pwr_time_old = pwr_time
    pwr_avg  = '-'
    gas_avg  = '-'

    while True:
        print('.' , end = '')
        if time()-secs > max_time:
            datagram = read_datagram(next(read_telegram()))
            if pwr_time != datagram['date_time']:
                pwr_time_old = pwr_time
                pwr_time = datagram['date_time']
                pwr_time_delta = pwr_time - pwr_time_old
                pwr      = datagram['tarif_1_delivered'] + datagram['tarif_2_delivered']
                pwr_avg  = round(((pwr - pwr_old)*60*60*1000)/pwr_time_delta) # convert from kWh to Ws
                pwr_old = pwr
            if gas_time != datagram['gas_read_time']:
                gas_time_old = gas_time
                gas_time = datagram['gas_read_time']
                gas_time_delta = gas_time - gas_time_old
                gas      = datagram['gas_delivered']
                gas_avg  = round(((gas - gas_old)*1000*1000)/gas_time_delta) #convert to ml / sec
                gas_old = gas
            datagram['power_delivered'] = pwr # total power delivered
            datagram['power_avg'] = pwr_avg # either None, old value or new value, dept on update
            datagram['gas_avg'] = gas_avg   # either None, old value or new value, dept on update
            datagram['last_reset'] = '1970-01-01T00:00:00+00:00'
#            print('{:3} current_power {:10} last_power {:10} diff {}'.format(round(time()-secs), pwr  , pwr_old, pwr_avg))
#            print('{:3} current gas   {:10} last gas   {:10} diff {}'.format(round(time()-secs),gas, gas_old, gas_avg))
#            print(round(time()-secs), 'gas', gas_avg, 'power', pwr_avg)
#            print('gas {:10} power {:10}'.format(datagram['gas_avg'], datagram['power_avg']))
            print('\n{} total power {} total gas {} power used {} gas used {}'.format(datagram['date_time_str'], pwr, gas, pwr_avg, gas_avg))
            mqtt_client.publish(power_topic, dumps(datagram))
            secs = time()
        sleep(1)

if __name__ == '__main__':
    main()
