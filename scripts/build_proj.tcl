
set root_dir ..
set proj_name SDNet_proj
set top example_top
set part xcu250-figd2104-2L-e
set board_part xilinx.com:au250:part0:1.3

create_project ${proj_name} ${root_dir}/${proj_name} -part $part
set_property board_part $board_part [current_project]

set proj_dir [get_property DIRECTORY [current_project]]

# Build SDNet IP
source build_sdnet.tcl

# Build AXI-Stream width converter (512-bit --> 64-bit)
set tx_dwidth_converter axis_tx_dwidth_converter
create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name $tx_dwidth_converter
set_property -dict {
    CONFIG.S_TDATA_NUM_BYTES {64}
    CONFIG.M_TDATA_NUM_BYTES {8}
    CONFIG.HAS_TLAST {1}
    CONFIG.HAS_TKEEP {1}
} [get_ips $tx_dwidth_converter]
generate_target all [get_ips $tx_dwidth_converter]

# Add simulation files
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -norecurse -quiet -fileset sim_1 [glob -nocomplain -directory ${root_dir}/vsrc "*.v"]
add_files -norecurse -quiet -fileset sim_1 [glob -nocomplain -directory ${root_dir}/vsrc "*.sv"]

set_property top $top [get_filesets sim_1]
update_compile_order -fileset sim_1

# Compile sim_network DPI files
exec make -C ${root_dir}/csrc
set sim_net_dpi ${proj_dir}/../csrc/xsim.dir/work/xsc/sim_net_dpi.so
if {![file exists $sim_net_dpi]} {
    puts "ERROR: failed to build \[$sim_net_dpi\]"
    return
}

# Link compiled DPI files into simulation elaboration phase
set cur_opts [get_property {xsim.elaborate.xelab.more_options} [get_filesets sim_1]]
set new_opts "${cur_opts} -sv_lib ${sim_net_dpi} -sv_root \"\""
set_property -name {xsim.elaborate.xelab.more_options} -value $new_opts -objects [get_filesets sim_1]

