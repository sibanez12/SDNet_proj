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

module example_stimulus # (
   parameter int TDATA_NUM_BYTES           = 64,
   parameter int USER_META_DATA_WIDTH      = 1
) (
   // Clock & Reset
   input  logic                            axis_aclk,
   input  logic                            axis_aresetn,
   // Meta Data
   output logic                            user_metadata_valid,
   output logic [USER_META_DATA_WIDTH-1:0] user_metadata,
   // Packet Data
   input  logic                            m_axis_tready,
   output logic                            m_axis_tvalid,
   output logic                            m_axis_tlast,
   output logic [TDATA_NUM_BYTES-1:0]      m_axis_tkeep,
   output logic [(TDATA_NUM_BYTES*8)-1:0]  m_axis_tdata,
   // Sequencing  
   input  logic                            traffic_start,
   input  string                           traffic_filename,
   output int                              packets_sent,
   output logic                            stimulus_done
);

   // Inter Packet Gap
   parameter IPG_SIZE = 3;
   logic     ipg_on;
   logic     ipg_rdy;
   integer   ipg_cnt;

   // counters
   integer pktCnt;
   integer wrdCnt;

   // Misc logic
   AXIS_T                           stimuli_packet[$];
   logic [USER_META_DATA_WIDTH-1:0] stimuli_user_metadata[$];
   logic                            traffic_enabled = 0;
   logic                            SOP = 1;
   
   // read packet & metadata stimulus file
   always @(posedge axis_aclk) begin
      if (traffic_start && !traffic_enabled) begin
         traffic_enabled <= 1;
         parse_packet_file($sformatf("%s_in", traffic_filename), stimuli_packet);
         parse_metadata_file($sformatf("%s_in", traffic_filename), stimuli_user_metadata);
      end else if (stimulus_done && traffic_enabled) begin
         traffic_enabled <= 0;
      end
   end
   
   // inter-packet gap generation
   assign ipg_rdy = (m_axis_tlast & m_axis_tvalid & IPG_SIZE > 0) | (ipg_on & (ipg_cnt < IPG_SIZE));
   always @(posedge axis_aclk) begin   
      if (!axis_aresetn) begin
         ipg_cnt <= 0;
         ipg_on  <= 0;
      end else begin
         if (ipg_rdy) begin
            ipg_on  <= 1;
            ipg_cnt <= ipg_cnt + 1;
         end else begin
            ipg_on  <= 0;
            ipg_cnt <= 0;
         end  
      end
   end

   // packet and word counter
   always @(posedge axis_aclk) begin
       if (!axis_aresetn) begin
           pktCnt       <= 0;
           wrdCnt       <= 0;
           packets_sent <= 0;
       end else begin
           if (stimulus_done) begin
              wrdCnt <= 0;
              pktCnt <= 0;
           end else if (m_axis_tready && traffic_enabled) begin
              if ((SOP || m_axis_tvalid) && !ipg_rdy) begin
                  wrdCnt <= wrdCnt + 1;
              end
              if (m_axis_tlast && m_axis_tvalid) begin
                 pktCnt <= pktCnt + 1;
                 packets_sent <= packets_sent + 1;
              end
           end
       end
   end
   
   // send packet data
   always @(posedge axis_aclk) begin   
      if (!axis_aresetn) begin
         stimulus_done <= 0;
         m_axis_tlast  <= 0;
         m_axis_tkeep  <= 0;
         m_axis_tvalid <= 0;
         m_axis_tdata  <= 0;
         SOP           <= 1;
      end else begin
         stimulus_done <= 0;
         if (m_axis_tready && traffic_enabled) begin
            if (stimuli_packet.size() > wrdCnt) begin   
                m_axis_tvalid <= ~ipg_rdy;
                m_axis_tdata  <= stimuli_packet[wrdCnt].tdata;
                m_axis_tkeep  <= stimuli_packet[wrdCnt].tkeep;
                m_axis_tlast  <= stimuli_packet[wrdCnt].tlast;
                SOP           <= stimuli_packet[wrdCnt].tlast | ipg_rdy;
            end else begin
                m_axis_tvalid <= 0;
            end
            if (wrdCnt == stimuli_packet.size() && !stimulus_done) begin
                $display("** Info: Finished stimulus");
                stimulus_done <= 1;
            end
         end         
      end
   end

   // send meta data       
   always @(posedge axis_aclk) begin   
      if (!axis_aresetn) begin
         user_metadata_valid <= 0;
         user_metadata       <= 0;
      end else begin  
        if (m_axis_tready && traffic_enabled) begin      
            if (SOP && stimuli_user_metadata.size() > pktCnt) begin
                user_metadata       <= stimuli_user_metadata[pktCnt];
                user_metadata_valid <= ~ipg_rdy;
            end else begin
                user_metadata       <= 0;
                user_metadata_valid <= 0;
            end
         end
      end
   end

endmodule

