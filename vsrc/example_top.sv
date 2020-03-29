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
   
   // Metadata
   USER_META_DATA_T user_metadata_in;
   logic            user_metadata_in_valid;
   USER_META_DATA_T user_metadata_out;
   logic            user_metadata_out_valid;
   
   // AXI Slave port
   logic [TDATA_NUM_BYTES*8-1:0] s_axis_tdata;
   logic [TDATA_NUM_BYTES-1:0]   s_axis_tkeep;
   logic                         s_axis_tvalid;
   logic                         s_axis_tlast;
   logic                         s_axis_tready;

   // AXI Master port
   logic [TDATA_NUM_BYTES*8-1:0] m_axis_tdata;
   logic [TDATA_NUM_BYTES-1:0]   m_axis_tkeep;
   logic                         m_axis_tvalid;
   logic                         m_axis_tready;
   logic                         m_axis_tlast;
   
   // AXI4-lite interface
   logic [S_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr;
   logic                          s_axi_awvalid;
   logic                          s_axi_awready;
   logic [S_AXI_DATA_WIDTH-1:0]   s_axi_wdata;
   logic [S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb;
   logic                          s_axi_wvalid;
   logic                          s_axi_wready;
   logic [1:0]                    s_axi_bresp;
   logic                          s_axi_bvalid;
   logic                          s_axi_bready;
   logic [S_AXI_ADDR_WIDTH-1:0]   s_axi_araddr;
   logic                          s_axi_arvalid;
   logic                          s_axi_arready;
   logic [S_AXI_DATA_WIDTH-1:0]   s_axi_rdata;
   logic                          s_axi_rvalid;
   logic                          s_axi_rready;
   logic [1:0]                    s_axi_rresp;
   


   // Sequencing
   logic  apb_complete;
   logic  traffic_start;
   logic  stimulus_done;
   logic  checker_done;
   int    meta_mismatch_count;
   int    pkt_mismatch_count;
   int    stimulus_pkt_count;
   int    checker_pkt_count;
   string traffic_filename;

   // --------------------------------------------------------------------------
   // Instantiate DUT
   
   sdnet_0 DUT (
      // Clocks & Resets
      .s_axis_aclk             (s_axis_aclk),
      .s_axis_aresetn          (s_axis_aresetn),
      .cam_mem_aclk            (cam_mem_aclk),
      .cam_mem_aresetn         (cam_mem_aresetn),
      .s_axi_aclk              (s_axi_aclk),
      .s_axi_aresetn           (s_axi_aresetn),
      .m_axi_hbm_aclk          (m_axi_hbm_aclk),
      .m_axi_hbm_aresetn       (m_axi_hbm_aresetn),
      // Metadata
      .user_metadata_in        (user_metadata_in),
      .user_metadata_in_valid  (user_metadata_in_valid),
      .user_metadata_out       (user_metadata_out),
      .user_metadata_out_valid (user_metadata_out_valid),
      // AXI Slave port
      .s_axis_tdata            (s_axis_tdata),
      .s_axis_tkeep            (s_axis_tkeep),
      .s_axis_tvalid           (s_axis_tvalid),
      .s_axis_tlast            (s_axis_tlast),
      .s_axis_tready           (s_axis_tready),
      // AXI Master port
      .m_axis_tdata            (m_axis_tdata),
      .m_axis_tkeep            (m_axis_tkeep),
      .m_axis_tvalid           (m_axis_tvalid),
      .m_axis_tready           (m_axis_tready),
      .m_axis_tlast            (m_axis_tlast),
       // Slave AXI-lite interface
      .s_axi_awaddr            (s_axi_awaddr),
      .s_axi_awvalid           (s_axi_awvalid),
      .s_axi_awready           (s_axi_awready),
      .s_axi_wdata             (s_axi_wdata),
      .s_axi_wstrb             (s_axi_wstrb),
      .s_axi_wvalid            (s_axi_wvalid),
      .s_axi_wready            (s_axi_wready),
      .s_axi_bresp             (s_axi_bresp),
      .s_axi_bvalid            (s_axi_bvalid),
      .s_axi_bready            (s_axi_bready),
      .s_axi_araddr            (s_axi_araddr),
      .s_axi_arvalid           (s_axi_arvalid),
      .s_axi_arready           (s_axi_arready),
      .s_axi_rdata             (s_axi_rdata),
      .s_axi_rvalid            (s_axi_rvalid),
      .s_axi_rready            (s_axi_rready),
      .s_axi_rresp             (s_axi_rresp)
   );
   
   // --------------------------------------------------------------------------
   // Instantiate control stimulus block 

   example_control #(
      .AXI_ADDR_WIDTH      (S_AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH      (S_AXI_DATA_WIDTH)
   ) example_control (
      // Clock & Reset
      .axi_aclk            (s_axi_aclk),
      .axi_aresetn         (s_axi_aresetn & apb_complete),
      // AXI4-lite interface
      .m_axi_awaddr        (s_axi_awaddr),
      .m_axi_awvalid       (s_axi_awvalid),
      .m_axi_awready       (s_axi_awready),
      .m_axi_wdata         (s_axi_wdata),
      .m_axi_wstrb         (s_axi_wstrb),
      .m_axi_wvalid        (s_axi_wvalid),
      .m_axi_wready        (s_axi_wready),
      .m_axi_bresp         (s_axi_bresp),
      .m_axi_bvalid        (s_axi_bvalid),
      .m_axi_bready        (s_axi_bready),
      .m_axi_araddr        (s_axi_araddr),
      .m_axi_arvalid       (s_axi_arvalid),
      .m_axi_arready       (s_axi_arready),
      .m_axi_rdata         (s_axi_rdata),
      .m_axi_rvalid        (s_axi_rvalid),
      .m_axi_rready        (s_axi_rready),
      .m_axi_rresp         (s_axi_rresp),     
      // Sequencing    
      .stimulus_done       (stimulus_done),
      .checker_done        (checker_done),
      .meta_mismatch_count (meta_mismatch_count),
      .pkt_mismatch_count  (pkt_mismatch_count),
      .stimulus_pkt_count  (stimulus_pkt_count),
      .checker_pkt_count   (checker_pkt_count),
      .traffic_start       (traffic_start),
      .traffic_filename    (traffic_filename)
   );

   // --------------------------------------------------------------------------
   // Instantiate data stimulus block
   
   example_stimulus #(
      .TDATA_NUM_BYTES      (TDATA_NUM_BYTES),
      .USER_META_DATA_WIDTH (USER_META_DATA_WIDTH)
   ) example_stimulus (
      // Clocks & Resets
      .axis_aclk            (s_axis_aclk),
      .axis_aresetn         (s_axis_aresetn),
      // Meta Data
      .user_metadata_valid  (user_metadata_in_valid),
      .user_metadata        (user_metadata_in),
      // Packet Data
      .m_axis_tready        (s_axis_tready),
      .m_axis_tvalid        (s_axis_tvalid),
      .m_axis_tlast         (s_axis_tlast),
      .m_axis_tkeep         (s_axis_tkeep),
      .m_axis_tdata         (s_axis_tdata),
      // Sequencing   
      .traffic_start        (traffic_start),
      .traffic_filename     (traffic_filename),
      .packets_sent         (stimulus_pkt_count),
      .stimulus_done        (stimulus_done)
   );

   // --------------------------------------------------------------------------
   // Instantiate checker block

   example_checker #(
      .TDATA_NUM_BYTES      (TDATA_NUM_BYTES),
      .USER_META_DATA_WIDTH (USER_META_DATA_WIDTH)
   ) example_checker (
      // Clocks & Resets
      .axis_aclk            (s_axis_aclk),
      .axis_aresetn         (s_axis_aresetn),
      // Meta Data          
      .user_metadata_valid  (user_metadata_out_valid),
      .user_metadata        (user_metadata_out),
      // Packet Data        
      .s_axis_tready        (m_axis_tready),
      .s_axis_tvalid        (m_axis_tvalid),
      .s_axis_tlast         (m_axis_tlast),
      .s_axis_tkeep         (m_axis_tkeep),
      .s_axis_tdata         (m_axis_tdata),
      // Sequencing   
      .traffic_start        (traffic_start),
      .traffic_filename     (traffic_filename),
      .checker_done         (checker_done),
      .packets_received     (checker_pkt_count),
      .meta_mismatch_count  (meta_mismatch_count),
      .pkt_mismatch_count   (pkt_mismatch_count)
   );


    assign apb_complete = s_axis_aresetn;

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

