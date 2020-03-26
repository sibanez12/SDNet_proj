
import unittest
from scapy.all import *
from LNIC_headers import LNIC, App
import time

TEST_IFACE = "tap0"

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

class SDNetTest(unittest.TestCase):
#    def test_net2cpu(self):
#        pkt_len = 64 # bytes
#        msg_len = pkt_len - len(lnic_req()) # bytes
#        payload = Raw('\x00'*msg_len)
#        request = lnic_req() / payload
#        print "Request:"
#        request.show2()
#        hexdump(request)
#        # Start sniffer for response packets
#        filt = lambda x: App(str(x)).ipv4_addr == MY_IP
#        sniffer = AsyncSniffer(iface=TEST_IFACE, lfilter=filt,
#                    count=1, timeout=5)
#        sniffer.start()
#        # Send in test packet
#        sendp(request, iface=TEST_IFACE)
#        # Wait for response
#        sniffer.join()
#        # Check response
#        self.assertEqual(len(sniffer.results), 1)
#        response = App(str(sniffer.results[0]))
#        print "Response:"
#        response.show2()
#        hexdump(response)
#        self.assertEqual(response.ipv4_addr, MY_IP)
#        self.assertEqual(response.lnic_addr, MY_CONTEXT)
#        self.assertEqual(response.msg_len, msg_len)

    def test_cpu2net(self):
        msg_len = 16 # bytes
        request = App(ipv4_addr=MY_IP, lnic_addr=MY_CONTEXT, msg_len=16) / ('\x00'*msg_len)
        print "Request:"
        request.show2()
        hexdump(request)
        # Start sniffer for response packets
        filt = lambda x: x.haslayer(Ether) and x[Ether].dst == MY_MAC
        sniffer = AsyncSniffer(iface=TEST_IFACE, lfilter=filt,
                    count=1, timeout=5)
        sniffer.start()
        time.sleep(0.5)
        # Send in test packet
        sendp(request, iface=TEST_IFACE)
        # Wait for response
        sniffer.join()
        # Check response
        self.assertEqual(len(sniffer.results), 1)
        response = sniffer.results[0]
        print "Response:"
        response.show2()
        hexdump(response)
        self.assertTrue(response.haslayer(IP))
        self.assertTrue(response.haslayer(LNIC))
        self.assertEqual(len(response), 64)
        self.assertEqual(response[Ether].src, NIC_MAC)
        self.assertEqual(response[IP].dst, MY_IP)
        self.assertEqual(response[IP].src, NIC_IP)


if __name__ == '__main__':
    unittest.main()

