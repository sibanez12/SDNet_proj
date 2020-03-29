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

module example_checker # (
   parameter int TDATA_NUM_BYTES           = 64,
   parameter int USER_META_DATA_WIDTH      = 1
) (
   // Clock & Reset
   input  logic                            axis_aclk,
   input  logic                            axis_aresetn,
   // Meta Data
   input  logic                            user_metadata_valid,
   input  logic [USER_META_DATA_WIDTH-1:0] user_metadata,
   // Packet Data
   output logic                            s_axis_tready,
   input  logic                            s_axis_tvalid,
   input  logic                            s_axis_tlast,
   input  logic [TDATA_NUM_BYTES-1:0]      s_axis_tkeep,
   input  logic [(TDATA_NUM_BYTES*8)-1:0]  s_axis_tdata,
   // Sequencing  
   input  logic                            traffic_start,
   input  string                           traffic_filename,
   output logic                            checker_done,
   output int                              packets_received,
   output int                              meta_mismatch_count,
   output int                              pkt_mismatch_count
);

   // counters
   integer pktCnt;
   integer wrdCnt;
   
   // Misc logic
   AXIS_T                           expected_packet[$];
   logic [USER_META_DATA_WIDTH-1:0] expected_user_metadata[$];
   logic [(TDATA_NUM_BYTES*8)-1:0]  s_axis_mask;
   logic                            traffic_enabled = 0;

   // read packet & metadata expected file
   always @(posedge axis_aclk) begin
      if (traffic_start && !traffic_enabled) begin
         traffic_enabled <= 1;
         parse_packet_file($sformatf("%s_out", traffic_filename), expected_packet);
         parse_metadata_file($sformatf("%s_out", traffic_filename), expected_user_metadata);
      end else if (checker_done && traffic_enabled) begin
         traffic_enabled <= 0;
      end
   end

   // packet and word counter
   always @(posedge axis_aclk) begin
       if (!axis_aresetn) begin
           pktCnt           <= 0;
           wrdCnt           <= 0;
           packets_received <= 0;
       end else begin
           if (checker_done) begin
               wrdCnt <= 0;
               pktCnt <= 0;
           end else if (s_axis_tvalid && s_axis_tready && traffic_enabled) begin
               wrdCnt <= wrdCnt + 1;
               if (s_axis_tlast) begin
                  pktCnt <= pktCnt + 1;
                  packets_received <= packets_received + 1;
               end
           end
       end
   end
   
   // AXIS tkeep mask
   always @(s_axis_tkeep) begin
      for (int b = 0; b < TDATA_NUM_BYTES; b++) begin
         s_axis_mask[b*8+:8] = {8{s_axis_tkeep[b]}};
      end
   end

   // Check packet data
   always @(posedge axis_aclk) begin
      if (!axis_aresetn) begin
          checker_done       <= 0;
          pkt_mismatch_count <= 0;
      end else begin
          checker_done <= 0;
          if (s_axis_tready && traffic_enabled) begin
              if (s_axis_tvalid && expected_packet.size() > wrdCnt) begin
                  if ((expected_packet[wrdCnt].tlast == s_axis_tlast) && 
                      (expected_packet[wrdCnt].tkeep == s_axis_tkeep) && 
                      (expected_packet[wrdCnt].tdata == (s_axis_tdata & s_axis_mask))) begin
                      $display("** Info: Packet %0d data OK (tlast, tkeep, tdata) = (%b, %x, %x) at time %t ps", pktCnt+1, s_axis_tlast, s_axis_tkeep, s_axis_tdata, $time);
                  end 
                  else begin
                      $display("** Error: Packet mismatch in packet %0d at time %0d ps", pktCnt+1, $time);
                      $display("  - Expected (tlast, tkeep, tdata) = (%b, %x, %x)", expected_packet[wrdCnt].tlast, expected_packet[wrdCnt].tkeep, expected_packet[wrdCnt].tdata);
                      $display("  - Captured (tlast, tkeep, tdata) = (%b, %x, %x)", s_axis_tlast, s_axis_tkeep, ( s_axis_tdata & s_axis_mask ));
                      pkt_mismatch_count <= pkt_mismatch_count + 1;
                  end
              end
              if (wrdCnt == expected_packet.size() && !checker_done) begin
                  $display("** Info: Finished checker");
                  checker_done <= 1;
              end
          end
      end
   end
   
   // Check metadata
   always @(posedge axis_aclk) begin
       if (!axis_aresetn) begin
          meta_mismatch_count <= 0;
       end else begin
          if (s_axis_tready && traffic_enabled) begin
               if (user_metadata_valid && expected_packet.size() > wrdCnt) begin
                   if (user_metadata == expected_user_metadata[pktCnt]) begin
                       $display("** Info: Packet %0d metadata OK (user_metadata) = (%x) at time %t ps", pktCnt+1, user_metadata, $time);
                   end
                   else begin
                       $display("** Error: Metadata mismatch for packet %0d at time %t ps", pktCnt+1, $time);
                       $display("**  - Expected (user_metadata) = (%x)", expected_user_metadata[pktCnt]);
                       $display("**  - Captured (user_metadata) = (%x)", user_metadata);
                       meta_mismatch_count <= meta_mismatch_count + 1;
                   end
               end
          end
       end
   end

   // assign outputs
   assign s_axis_tready = 1;

endmodule

