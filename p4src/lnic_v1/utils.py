
def pkt_to_bytes(pkt):
    pkt_bytes = ['{:02x}'.format(ord(b)) for b in str(pkt)]
    pkt_bytes.append(';')
    return ' '.join(pkt_bytes)

def write_traffic_file(pkts, filename):
    result = ""
    for p in pkts:
        result += pkt_to_bytes(p)
        result += "\n"
    with open(filename, "w") as f:
        f.write(result)

