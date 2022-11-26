# /usr/bin/env python3
import serial

def read_telegram():
    """ Reads the serial port until we can create a reading point. """
    serial_handle = serial.Serial()
    serial_handle.port = '/dev/ttyUSB0'
    serial_handle.baudrate = 115200
    serial_handle.bytesize = serial.EIGHTBITS
    serial_handle.parity = serial.PARITY_NONE
    serial_handle.stopbits = serial.STOPBITS_ONE
    serial_handle.xonxoff = 1
    serial_handle.rtscts = 0
    serial_handle.timeout = 20

    # This might fail, but nothing we can do so just let it crash.
    serial_handle.open()

    telegram_start_seen = False
    buffer = ''

    # Just keep fetching data until we got what we were looking for.
    while True:
        try:
            data = serial_handle.readline()
        except SerialException as error: # Something else and unexpected failed.
            print('Serial connection failed:', error)
            return  # Break out of yield.

        try:
            data = str(data, 'utf-8') # Make sure weird characters are converted properly.
        except TypeError:
            pass

        # This guarantees we will only parse complete telegrams. (issue #74)
        if data.startswith('/'):
            telegram_start_seen = True
            buffer = ''

        # Delay any logging until we've seen the start of a telegram.
        if telegram_start_seen:
            buffer += data

        # Telegrams ends with '!' AND we saw the start. We should have a complete telegram now.
        if data.startswith('!') and telegram_start_seen:
            yield buffer

            # Reset the flow again.
            telegram_start_seen = False
            buffer = ''

if __name__ == '__main__':
    for line in read_telegram():
        print(line)
