
from scapy.all import *
import struct

LNIC_PROTO = 0x99

class LNIC(Packet):
    name = "LNIC"
    fields_desc = [
        ShortField("src", 0),
        ShortField("dst", 0),
        ShortField("msg_id", 0),
        # msg_len will default to size of payload
        ShortField("msg_len", None),
        ShortField("offset", 0),
        IntField("padding", 0)
    ]
    def post_build(self, p, pay):
        if self.msg_len is None:
            l = len(pay)
            p = p[:6]+struct.pack("!H", l)+p[8:]
        return p+pay


class App(Packet):
    name = "App"
    fields_desc = [
        IPField("ipv4_addr", "0.0.0.0"),
        ShortField("lnic_addr", 0),
        ShortField("msg_len", 0)
    ]    

bind_layers(IP, LNIC, proto=LNIC_PROTO)

