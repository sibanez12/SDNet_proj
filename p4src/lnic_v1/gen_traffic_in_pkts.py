
from scapy.all import *
from LNIC_headers import LNIC, App
from utils import write_traffic_file

NIC_MAC = "08:11:22:33:44:08"
MY_MAC = "08:55:66:77:88:08"

NIC_IP = "10.0.0.1"
MY_IP = "10.1.2.3"

DST_CONTEXT = 0
MY_CONTEXT = 0x1234

def lnic_req(my_context=MY_CONTEXT, lnic_dst=DST_CONTEXT):
    return Ether(dst=NIC_MAC, src=MY_MAC) / \
            IP(src=MY_IP, dst=NIC_IP) / \
            LNIC(src=my_context, dst=lnic_dst)

pkts = []

# Packet 1
pkt_len = 64 # bytes
pkt = lnic_req() / ('\x00'*(pkt_len - len(lnic_req())))
pkts.append(pkt)

# Packet 2
msg_len = 16 # bytes
pkt = App(ipv4_addr=MY_IP, lnic_addr=MY_CONTEXT, msg_len=msg_len) / ('\x00'*msg_len)
pkts.append(pkt)

write_traffic_file(pkts, "traffic_in.user")

