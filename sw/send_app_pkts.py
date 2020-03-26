
from scapy.all import *
from LNIC_headers import App

TEST_IFACE = "tap0"

NIC_MAC = "08:11:22:33:44:08"
MY_MAC = "08:55:66:77:88:08"

NIC_IP = "10.0.0.1"
MY_IP = "10.1.2.3"

DST_CONTEXT = 0
MY_CONTEXT = 0x1234

MSG_LEN = 16 # bytes
NUM_MSGS = 3

msg = App(ipv4_addr=MY_IP, lnic_addr=MY_CONTEXT, msg_len=16) / ('\x00'*MSG_LEN)

print "Sending the following msg {} times:".format(NUM_MSGS)
msg.show2()
hexdump(msg)

for i in range(NUM_MSGS):
    sendp(msg, iface=TEST_IFACE)

