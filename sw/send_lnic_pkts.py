
from scapy.all import *
from LNIC_headers import LNIC

TEST_IFACE = "tap0"

NIC_MAC = "08:11:22:33:44:08"
MY_MAC = "08:55:66:77:88:08"

NIC_IP = "10.0.0.1"
MY_IP = "10.1.2.3"

DST_CONTEXT = 0
MY_CONTEXT = 0x1234

PKT_LEN = 64 # bytes
NUM_PKTS = 3

def lnic_req(my_context=MY_CONTEXT, lnic_dst=DST_CONTEXT):
    return Ether(dst=NIC_MAC, src=MY_MAC) / \
            IP(src=MY_IP, dst=NIC_IP) / \
            LNIC(src=my_context, dst=lnic_dst)

pkt = lnic_req() / ('\x00'*(PKT_LEN - len(lnic_req())))

print "Sending the following pkt {} times:".format(NUM_PKTS)
pkt.show2()
hexdump(pkt)

for i in range(NUM_PKTS):
    sendp(pkt, iface=TEST_IFACE)

