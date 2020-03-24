#ifndef __NET_DEVICE_H__
#define __NET_DEVICE_H__

#include <vpi_user.h>
#include <svdpi.h>

#include <queue>
#include <stdint.h>
#include <cassert>

#include "packet.hpp"

class NetworkDevice {
  public:
    NetworkDevice(const char *ifname);
    ~NetworkDevice();

    void tick_tx(bool tx_valid,
                 uint64_t tx_data,
                 uint8_t tx_keep,
                 bool tx_last);

    void tick_rx(bool rx_ready);

    bool tx_ready() { return true; }
    bool rx_valid() { return !rx_flits.empty(); }
    uint64_t rx_data() { return (rx_valid()) ? rx_flits.front().data : 0; }
    uint8_t rx_keep() { return (rx_valid()) ? rx_flits.front().keep : 0; }
    bool rx_last() { return (rx_valid()) ? rx_flits.front().last : false; }

  protected:
    int fd;
    std::queue<network_flit> tx_flits;
    std::queue<network_flit> rx_flits;

    std::queue<network_packet*> tx_packets;
    std::queue<network_packet*> rx_packets;

};

#endif
