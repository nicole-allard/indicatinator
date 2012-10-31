require 'rubygems'  
require 'serialport'

#params for serial port  
port_str = "/dev/ttyACM0"
#port_str = "/dev/tty.usbmodemfa131"
baud_rate = 9600
data_bits = 8 
stop_bits = 1 
parity = SerialPort::NONE  

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)  
sleep(3)
sp.write(ARGV[0].to_i.chr || 0.chr)
