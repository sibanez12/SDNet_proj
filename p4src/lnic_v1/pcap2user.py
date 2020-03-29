
import argparse, sys, os
from scapy.all import *
from utils import write_traffic_file

pkts = rdpcap("traffic_out.pcap")
write_traffic_file(pkts, "traffic_out.user")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('pcap', type=str, help="pcap file to read")
    parser.add_argument('user', type=str, help="user file to write")
    args = parser.parse_args()

    pkts = rdpcap(args.pcap)
    write_traffic_file(pkts, args.user)

if __name__ == "__main__":
    main()

