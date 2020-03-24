
// *************************************************************************
//
// Copyright (c) 2020 Stanford University All rights reserved.
//
// This software was developed by
// Stanford University and the University of Cambridge Computer Laboratory
// under National Science Foundation under Grant No. CNS-0855268,
// the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
// by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"),
// as part of the DARPA MRC research programme.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
// *************************************************************************
// NOTE: machine-generated file --- DO NOT EDIT!!
// *************************************************************************
`timescale 1ns/1ps

import sdnet_0_pkg::*;

module sdnet_wrapper #(
  parameter TDATA_W = 64,
  parameter TUSER_W = 128
) (
  input                     s_axil_awvalid,
  input              [31:0] s_axil_awaddr,
  output                    s_axil_awready,
  input                     s_axil_wvalid,
  input              [31:0] s_axil_wdata,
  output                    s_axil_wready,
  output                    s_axil_bvalid,
  output              [1:0] s_axil_bresp,
  input                     s_axil_bready,
  input                     s_axil_arvalid,
  input              [31:0] s_axil_araddr,
  output                    s_axil_arready,
  output                    s_axil_rvalid,
  output             [31:0] s_axil_rdata,
  output              [1:0] s_axil_rresp,
  input                     s_axil_rready,

  input                     s_axis_tvalid,
  input       [TDATA_W-1:0] s_axis_tdata,
  input   [(TDATA_W/8)-1:0] s_axis_tkeep,
  input                     s_axis_tlast,
  input       [TUSER_W-1:0] s_axis_tuser,
  output                    s_axis_tready,
  input                     s_axis_tfirst,

  output                    m_axis_tvalid,
  output      [TDATA_W-1:0] m_axis_tdata,
  output  [(TDATA_W/8)-1:0] m_axis_tkeep,
  output                    m_axis_tlast,
  output      [TUSER_W-1:0] m_axis_tuser,
  input                     m_axis_tready,
  output                    m_axis_tfirst,

  input                     axi_aresetn,
  input                     axil_aclk,
  input                     axis_aclk
);

  wire                user_metadata_in_valid;
  USER_META_DATA_T    user_metadata_in;
  wire                user_metadata_out_valid;
  USER_META_DATA_T    user_metadata_out;

  assign user_metadata_in_valid = s_axis_tfirst;
  assign user_metadata_in = s_axis_tuser;
  assign m_axis_tfirst = user_metadata_out_valid;
  assign m_axis_tuser = user_metadata_out;

  // SDNet module
  sdnet_0 sdnet_inst (
    // Clocks & Resets
    .s_axis_aclk             (axis_aclk),
    .s_axis_aresetn          (axi_aresetn),
    .s_axi_aclk              (axil_aclk),
    .s_axi_aresetn           (axi_aresetn),
    // Metadata
    .user_metadata_in        (user_metadata_in),
    .user_metadata_in_valid  (user_metadata_in_valid),
    .user_metadata_out       (user_metadata_out),
    .user_metadata_out_valid (user_metadata_out_valid),
    // AXI4 Stream Slave port
    .s_axis_tdata            (s_axis_tdata),
    .s_axis_tkeep            (s_axis_tkeep),
    .s_axis_tvalid           (s_axis_tvalid),
    .s_axis_tlast            (s_axis_tlast),
    .s_axis_tready           (s_axis_tready),
    // AXI4 Stream Master port
    .m_axis_tdata            (m_axis_tdata),
    .m_axis_tkeep            (m_axis_tkeep),
    .m_axis_tvalid           (m_axis_tvalid),
    .m_axis_tready           (m_axis_tready),
    .m_axis_tlast            (m_axis_tlast),
     // Slave AXI-lite interface
    .s_axi_awaddr            (s_axil_awaddr),
    .s_axi_awvalid           (s_axil_awvalid),
    .s_axi_awready           (s_axil_awready),
    .s_axi_wdata             (s_axil_wdata),
    .s_axi_wstrb             (4'hF),
    .s_axi_wvalid            (s_axil_wvalid),
    .s_axi_wready            (s_axil_wready),
    .s_axi_bresp             (s_axil_bresp),
    .s_axi_bvalid            (s_axil_bvalid),
    .s_axi_bready            (s_axil_bready),
    .s_axi_araddr            (s_axil_araddr),
    .s_axi_arvalid           (s_axil_arvalid),
    .s_axi_arready           (s_axil_arready),
    .s_axi_rdata             (s_axil_rdata),
    .s_axi_rvalid            (s_axil_rvalid),
    .s_axi_rready            (s_axil_rready),
    .s_axi_rresp             (s_axil_rresp)
  );

endmodule: sdnet_wrapper
