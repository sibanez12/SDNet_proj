
set tdata_bytes 8

set proj_name [current_project]
set proj_dir [get_property DIRECTORY [current_project]]

source ${proj_dir}/../scripts/common.tcl

set p4_file ${proj_dir}/../p4src/${p4_proj}/${p4_proj}.p4
set sdnet sdnet_0

# Delete the sdnet IP if it already exists
if {![string equal [get_ips $sdnet] ""]} {
    puts "INFO: Deleting current ${sdnet} IP"
    remove_files ${proj_dir}/${proj_name}.srcs/sources_1/ip/${sdnet}/${sdnet}.xci
    file delete -force ${proj_dir}/${proj_name}.srcs/sources_1/ip/${sdnet}
}

# Generate a new sdnet_0 IP
create_ip -name sdnet -vendor xilinx.com -library ip -version 2.1 -module_name $sdnet
set_property -dict [subst {
    CONFIG.TDATA_NUM_BYTES {${tdata_bytes}}
    CONFIG.P4_FILE {${p4_file}}
    CONFIG.DEBUG_IO_CAPTURE_ENABLE {true}
    CONFIG.CAM_DEBUG_HW_LOOKUP {true}
    CONFIG.CAM_MEM_CLK_FREQ_MHZ {250.0}
    CONFIG.AXIS_CLK_FREQ_MHZ {250.0}
    CONFIG.PKT_RATE {250.0}
    CONFIG.DIRECT_TABLE_PARAMS {}
    CONFIG.CAM_TABLE_PARAMS {}
}] [get_ips $sdnet]
generate_target all [get_ips $sdnet]

