
import "DPI-C" function void network_tick (
    input string devname,

    input  bit     tx_valid,
    output bit     tx_ready,
    input  longint tx_data,
    input  byte    tx_keep,
    input  bit     tx_last,

    output bit     rx_valid,
    input  bit     rx_ready,
    output longint rx_data,
    output byte    rx_keep,
    output bit     rx_last
);

import "DPI-C" function void network_init (
    input string devname
);

module sim_network #(
  parameter DEVNAME = "tap0"
)
(
    input             clock,
    input             reset,

    // TX packets: HW --> tap iface
    input             net_tx_tvalid,
    output reg        net_tx_tready,
    input  [63:0]     net_tx_tdata,
    input  [7:0]      net_tx_tkeep,
    input             net_tx_tlast,

    // RX packets: tap iface --> HW
    output reg        net_rx_tvalid,
    input             net_rx_tready,
    output reg [63:0] net_rx_tdata,
    output reg [7:0]  net_rx_tkeep,
    output reg        net_rx_tlast
);

    string devname = DEVNAME;

    initial begin
        network_init(devname);
    end

    always@(posedge clock) begin
        if (reset) begin
            net_tx_tready <= 0;
            net_rx_tvalid <= 0;
            net_rx_tdata <= 0;
            net_rx_tkeep <= 0;
            net_rx_tlast <= 0;
        end
        else begin
            network_tick(
                devname,

                net_tx_tvalid,
                net_tx_tready,
                net_tx_tdata,
                net_tx_tkeep,
                net_tx_tlast,
    
                net_rx_tvalid,
                net_rx_tready,
                net_rx_tdata,
                net_rx_tkeep,
                net_rx_tlast);
        end
    end

endmodule
