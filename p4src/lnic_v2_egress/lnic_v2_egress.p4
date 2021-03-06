// ----------------------------------------------------------------------- //
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


#include <core.p4>
#include <xsa.p4>

typedef bit<48>  EthAddr_t;
typedef bit<32>  IPv4Addr_t;
typedef bit<16>  ContextID_t;

const EthAddr_t SWITCH_MAC_ADDR = 0x085566778808;
const EthAddr_t NIC_MAC_ADDR = 0x081122334408;
const IPv4Addr_t NIC_IP_ADDR = 0x0A000001;

const bit<16> IP_HDR_BYTES = 20;
const bit<16> LNIC_HDR_BYTES = 14;

const bit<16> IPV4_TYPE = 0x0800;
const bit<8> LNIC_PROTO = 0x99;

// IO metadata structure
struct nf_metadata {
    /* Input metadata for pkts from CPU (set by pktization module) */
    IPv4Addr_t dst_ip;
    ContextID_t lnic_dst;
    bit<16> offset;
    bit<16> msg_len;
    bit<16> msg_id;
    ContextID_t lnic_src;
}

// ****************************************************************************** //
// *************************** H E A D E R S  *********************************** //
// ****************************************************************************** //

// standard Ethernet header (14 bytes = 112 bits)
header eth_mac_t {
    EthAddr_t dstAddr;   // Destination MAC address
    EthAddr_t srcAddr;   // Source MAC address
    bit<16> etherType;   // Tag Protocol Identifier
}

// IPv4 header without options (20 bytes = 160 bits)
header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> tos;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdrChecksum;
    IPv4Addr_t srcAddr;
    IPv4Addr_t dstAddr;
}

// L-NIC transport header (14 bytes = 112 bits)
header lnic_t {
    ContextID_t src_context;
    ContextID_t dst_context;
    bit<16> msg_id;
    bit<16> msg_len;
    bit<16> offset;
    bit<32> padding; // used to make Ethernet, IP, LNIC hdrs 64-bit aligned for an easy parser implementation
}

// ****************************************************************************** //
// ************************* S T R U C T U R E S  ******************************* //
// ****************************************************************************** //

// header structure
struct headers {
    eth_mac_t  eth;
    ipv4_t     ipv4;
    lnic_t     lnic;
}

// ****************************************************************************** //
// *************************** P A R S E R  ************************************* //
// ****************************************************************************** //

parser MyParser(packet_in packet, 
                out headers hdr, 
                inout nf_metadata nfmeta, 
                inout standard_metadata_t smeta) {

    state start {
        transition accept;
    }

}

// ****************************************************************************** //
// **************************  P R O C E S S I N G   **************************** //
// ****************************************************************************** //

control MyProcessing(inout headers hdr, 
                     inout nf_metadata nfmeta, 
                     inout standard_metadata_t smeta) {

    apply {
        // packet from CPU
        hdr.eth.setValid();
        hdr.ipv4.setValid();
        hdr.lnic.setValid();

        // Fill out Ethernet header fields
        hdr.eth.dstAddr = SWITCH_MAC_ADDR;
        hdr.eth.srcAddr = NIC_MAC_ADDR;
        hdr.eth.etherType = IPV4_TYPE;

        // Fill out IPv4 header fields
        hdr.ipv4.version = 4;
        hdr.ipv4.ihl = 5;
        hdr.ipv4.tos = 0;
        hdr.ipv4.totalLen = nfmeta.msg_len + IP_HDR_BYTES + LNIC_HDR_BYTES;
        hdr.ipv4.identification = 1;
        hdr.ipv4.flags = 0;
        hdr.ipv4.fragOffset = 0;
        hdr.ipv4.ttl = 64;
        hdr.ipv4.protocol = LNIC_PROTO;
        hdr.ipv4.hdrChecksum = 0; // TODO(sibanez): implement this ...
        hdr.ipv4.srcAddr = NIC_IP_ADDR;
        hdr.ipv4.dstAddr = nfmeta.dst_ip;

        // Fill out LNIC header fields
        hdr.lnic.src_context = nfmeta.lnic_src;
        hdr.lnic.dst_context = nfmeta.lnic_dst;
        hdr.lnic.msg_id = nfmeta.msg_id;
        hdr.lnic.msg_len = nfmeta.msg_len;
        hdr.lnic.offset = nfmeta.offset;
        hdr.lnic.padding = 0;
    }
} 

// ****************************************************************************** //
// ***************************  D E P A R S E R  ******************************** //
// ****************************************************************************** //

control MyDeparser(packet_out packet, 
                   in headers hdr,
                   inout nf_metadata nfmeta, 
                   inout standard_metadata_t smeta) {
    apply {
        packet.emit(hdr.eth);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.lnic);
    }
}

// ****************************************************************************** //
// *******************************  M A I N  ************************************ //
// ****************************************************************************** //

XilinxPipeline(
    MyParser(), 
    MyProcessing(), 
    MyDeparser()
) main;
