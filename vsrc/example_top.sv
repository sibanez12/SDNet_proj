// --------------------------------------------------------------------------
//   This file is owned and controlled by Xilinx and must be used solely
//   for design, simulation, implementation and creation of design files
//   limited to Xilinx devices or technologies. Use with non-Xilinx
//   devices or technologies is expressly prohibited and immediately
//   terminates your license.
//
//   XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION 'AS IS' SOLELY
//   FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//   PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE
//   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS
//   MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY
//   CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY
//   RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY
//   DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
//   IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//   REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
//   INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//   PARTICULAR PURPOSE.
//
//   Xilinx products are not intended for use in life support appliances,
//   devices, or systems.  Use in such applications are expressly
//   prohibited.
//
//   (c) Copyright 1995-2018 Xilinx, Inc.
//   All rights reserved.
// --------------------------------------------------------------------------

import example_design_pkg::*;

module example_top ();

   // --------------------------------------------------------------------------
   // wiring
   
   // Clocks & Resets
   logic s_axis_aclk         = 1'b0;
   logic s_axis_aresetn      = 1'b0;
   logic cam_mem_aclk        = 1'b0;
   logic cam_mem_aresetn     = 1'b0;
   logic s_axi_aclk          = 1'b0;
   logic s_axi_aresetn       = 1'b0;
   logic m_axi_hbm_aclk      = 1'b0;
   logic m_axi_hbm_aresetn   = 1'b0;
   
   // AXI Slave port
   logic [TDATA_NUM_BYTES*8-1:0]    s_axis_tdata;
   logic [TDATA_NUM_BYTES-1:0]      s_axis_tkeep;
   logic                            s_axis_tvalid;
   logic                            s_axis_tlast;
   logic                            s_axis_tready;
   logic [USER_META_DATA_WIDTH-1:0] s_axis_tuser;
   logic                            s_axis_tfirst;

   // AXI Master port
   logic [TDATA_NUM_BYTES*8-1:0]    m_axis_tdata;
   logic [TDATA_NUM_BYTES-1:0]      m_axis_tkeep;
   logic                            m_axis_tvalid;
   logic                            m_axis_tready;
   logic                            m_axis_tlast;
   logic [USER_META_DATA_WIDTH-1:0] m_axis_tuser;
   logic                            m_axis_tfirst;

   logic                  [63:0]    s_axis_net_tdata;
   logic                   [7:0]    s_axis_net_tkeep;
   logic                            s_axis_net_tvalid;
   logic                            s_axis_net_tlast;
   logic                            s_axis_net_tready;

   logic                  [63:0]    m_axis_net_tdata;
   logic                   [7:0]    m_axis_net_tkeep;
   logic                            m_axis_net_tvalid;
   logic                            m_axis_net_tlast;
   logic                            m_axis_net_tready;
   
   // AXI4-lite interface
   logic [S_AXI_ADDR_WIDTH-1:0]   s_axil_awaddr;
   logic                          s_axil_awvalid;
   logic                          s_axil_awready;
   logic [S_AXI_DATA_WIDTH-1:0]   s_axil_wdata;
   logic [S_AXI_DATA_WIDTH/8-1:0] s_axil_wstrb;
   logic                          s_axil_wvalid;
   logic                          s_axil_wready;
   logic [1:0]                    s_axil_bresp;
   logic                          s_axil_bvalid;
   logic                          s_axil_bready;
   logic [S_AXI_ADDR_WIDTH-1:0]   s_axil_araddr;
   logic                          s_axil_arvalid;
   logic                          s_axil_arready;
   logic [S_AXI_DATA_WIDTH-1:0]   s_axil_rdata;
   logic                          s_axil_rvalid;
   logic                          s_axil_rready;
   logic [1:0]                    s_axil_rresp;
   

   // --------------------------------------------------------------------------
   // Instantiate DUT
   // SDNet wrapper module
   sdnet_wrapper
   #(
     .TDATA_W (TDATA_NUM_BYTES*8),
     .TUSER_W (USER_META_DATA_WIDTH)
   ) sdnet_wrapper_inst (
      // Clocks & Resets
      .axis_aclk               (s_axis_aclk),
      .axil_aclk               (s_axi_aclk),
      .axi_aresetn             (s_axi_aresetn),
      // AXI4 Stream Slave port
      .s_axis_tready           (s_axis_tready),
      .s_axis_tdata            (s_axis_tdata),
      .s_axis_tkeep            (s_axis_tkeep),
      .s_axis_tvalid           (s_axis_tvalid),
      .s_axis_tlast            (s_axis_tlast),
      .s_axis_tfirst           (s_axis_tfirst),
      .s_axis_tuser            (s_axis_tuser),
      // AXI4 Stream Master port
      .m_axis_tdata            (m_axis_tdata),
      .m_axis_tkeep            (m_axis_tkeep),
      .m_axis_tvalid           (m_axis_tvalid),
      .m_axis_tready           (m_axis_tready),
      .m_axis_tlast            (m_axis_tlast),
      .m_axis_tfirst           (m_axis_tfirst),
      .m_axis_tuser            (m_axis_tuser),
       // Slave AXI-lite interface
      .s_axil_awaddr            (s_axil_awaddr),
      .s_axil_awvalid           (s_axil_awvalid),
      .s_axil_awready           (s_axil_awready),
      .s_axil_wdata             (s_axil_wdata),
      .s_axil_wvalid            (s_axil_wvalid),
      .s_axil_wready            (s_axil_wready),
      .s_axil_bresp             (s_axil_bresp),
      .s_axil_bvalid            (s_axil_bvalid),
      .s_axil_bready            (s_axil_bready),
      .s_axil_araddr            (s_axil_araddr),
      .s_axil_arvalid           (s_axil_arvalid),
      .s_axil_arready           (s_axil_arready),
      .s_axil_rdata             (s_axil_rdata),
      .s_axil_rvalid            (s_axil_rvalid),
      .s_axil_rready            (s_axil_rready),
      .s_axil_rresp             (s_axil_rresp)
   );
   
   // --------------------------------------------------------------------------
   // Instantiate control stimulus block 

   /* Not needed for this P4 program */

   // --------------------------------------------------------------------------
   // Instantiate data stimulus block

   sim_network #(
       .DEVNAME ("tap0")
   ) sim_network_0 (
       // Clock & Reset
       .clock              (s_axis_aclk),
       .reset              (~s_axi_aresetn),
       // TX packets - going to TAP interface
       .net_tx_tvalid      (m_axis_net_tvalid),
       .net_tx_tdata       (m_axis_net_tdata),
       .net_tx_tkeep       (m_axis_net_tkeep),
       .net_tx_tlast       (m_axis_net_tlast),
       .net_tx_tready      (m_axis_net_tready),
       // RX packets - coming from TAP interface
       .net_rx_tvalid      (s_axis_net_tvalid),
       .net_rx_tready      (s_axis_net_tready),
       .net_rx_tdata       (s_axis_net_tdata),
       .net_rx_tkeep       (s_axis_net_tkeep),
       .net_rx_tlast       (s_axis_net_tlast)
   );

   generate
   if (TDATA_NUM_BYTES == 64) begin: WIDE_DP

   // Convert: 64-bit --> 512-bit
   nf_axis_converter #(
     .C_M_AXIS_DATA_WIDTH (TDATA_NUM_BYTES*8),
     .C_S_AXIS_DATA_WIDTH (64),
     .C_AXIS_TUSER_WIDTH (USER_META_DATA_WIDTH),
     .C_DEFAULT_VALUE_ENABLE (0) // don't change tuser, just pass it along
   ) rx_dwidth_converter_inst (
     .axi_aclk        (s_axis_aclk),
     .axi_resetn      (s_axi_aresetn),
 
     .s_axis_tvalid   (s_axis_net_tvalid),  // input wire s_axis_tvalid
     .s_axis_tready   (s_axis_net_tready),  // output wire s_axis_tready
     .s_axis_tdata    (s_axis_net_tdata),    // input wire [63 : 0] s_axis_tdata
     .s_axis_tkeep    (s_axis_net_tkeep),    // input wire [7 : 0] s_axis_tkeep
     .s_axis_tuser    (0),    // input wire [127 : 0] s_axis_tuser
     .s_axis_tlast    (s_axis_net_tlast),    // input wire s_axis_tlast
 
     .m_axis_tvalid   (s_axis_tvalid),  // output wire m_axis_tvalid
     .m_axis_tready   (s_axis_tready),  // input wire m_axis_tready
     .m_axis_tdata    (s_axis_tdata),    // output wire [511 : 0] m_axis_tdata
     .m_axis_tkeep    (s_axis_tkeep),    // output wire [63 : 0] m_axis_tkeep
     .m_axis_tuser    (),    // output wire [127 : 0] m_axis_tuser
     .m_axis_tlast    (s_axis_tlast)    // output wire m_axis_tlast
   );

   // Convert: 512-bit --> 64-bit
   axis_tx_dwidth_converter tx_dwidth_converter_inst (
     .aclk            (s_axis_aclk),                    // input wire aclk
     .aresetn         (s_axi_aresetn),              // input wire aresetn

     .s_axis_tvalid   (m_axis_tvalid),  // input wire s_axis_tvalid
     .s_axis_tready   (m_axis_tready),  // output wire s_axis_tready
     .s_axis_tdata    (m_axis_tdata),    // input wire [511 : 0] s_axis_tdata
     .s_axis_tkeep    (m_axis_tkeep),    // input wire [63 : 0] s_axis_tkeep
     .s_axis_tlast    (m_axis_tlast),    // input wire s_axis_tlast

     .m_axis_tvalid   (m_axis_net_tvalid),  // output wire m_axis_tvalid
     .m_axis_tready   (m_axis_net_tready),  // input wire m_axis_tready
     .m_axis_tdata    (m_axis_net_tdata),    // output wire [63 : 0] m_axis_tdata
     .m_axis_tkeep    (m_axis_net_tkeep),    // output wire [7 : 0] m_axis_tkeep
     .m_axis_tlast    (m_axis_net_tlast)    // output wire m_axis_tlast
   );

   end
   else if (TDATA_NUM_BYTES == 8) begin: NARROW_DP

   assign s_axis_tvalid = s_axis_net_tvalid;
   assign s_axis_tdata = s_axis_net_tdata;
   assign s_axis_tkeep = s_axis_net_tkeep;
   assign s_axis_tlast = s_axis_net_tlast;
   assign s_axis_net_tready = s_axis_tready;

   assign m_axis_net_tvalid = m_axis_tvalid;
   assign m_axis_net_tdata = m_axis_tdata;
   assign m_axis_net_tkeep = m_axis_tkeep;
   assign m_axis_net_tlast = m_axis_tlast;
   assign m_axis_tready = m_axis_net_tready;

   end
   endgenerate

   /*--------------------------------------*/
   /* State machine to drive s_axis_tfirst */
   /*--------------------------------------*/
   localparam START = 0;
   localparam WAIT_EOP = 1;

   reg state, state_next;

   always @(*) begin
     state_next = state;
     s_axis_tfirst = 0;
     s_axis_tuser = {1'b1, {(USER_META_DATA_WIDTH-1){1'b0}}};

     case (state)
       START: begin
         if (s_axis_tvalid) begin
           s_axis_tfirst = 1;
         end
         if (s_axis_tvalid & s_axis_tready & ~s_axis_tlast) begin
           state_next = WAIT_EOP;
         end
       end

       WAIT_EOP: begin
         if (s_axis_tvalid & s_axis_tready & s_axis_tlast) begin
           state_next = START;
         end
       end
     endcase
   end

   always @(posedge s_axis_aclk) begin
     if (~s_axi_aresetn) begin
       state <= START;
     end
     else begin
       state <= state_next;
     end
   end

   // --------------------------------------------------------------------------
   // Generate clocks and resets
   
   always begin
     #(1000000 / (2*AXIS_CLK_FREQ_MHZ)) s_axis_aclk = !s_axis_aclk;
   end
   
   always begin
     #(1000000 / (2*CAM_MEM_CLK_FREQ_MHZ)) cam_mem_aclk = !cam_mem_aclk;
   end

   always begin
     #(1000000 / (2*CTL_CLK_FREQ_MHZ)) s_axi_aclk = !s_axi_aclk;
   end

   always begin
     #(1000000 / (2*HBM_CLK_FREQ_MHZ)) m_axi_hbm_aclk = !m_axi_hbm_aclk;
   end
   
   initial begin
      #1000000 s_axis_aresetn = 1'b1;
   end

   initial begin
      #1000000 cam_mem_aresetn = 1'b1;
   end

   initial begin
      #1000000 s_axi_aresetn = 1'b1;
   end

   initial begin
      #1000000 m_axi_hbm_aresetn = 1'b1;
   end

endmodule

