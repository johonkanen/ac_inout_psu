package require ::quartus::project
package require ::quartus::flow
package require cmdline


# set options \
# {\
#     # { "load_program_to.arg"} \
#     # { "usb_cable.arg"} \
# }
#
# array set opts [::cmdline::getoptions quartus(args) $options]
#

variable cyclone_10_tcl_dir [ file dirname [ file normalize [ info script ] ] ]

set project_root $cyclone_10_tcl_dir/../../
set source_folder $project_root/source
set fpga_device 10CL025YU256I7G
set output_dir ./output

# if {[llength $output_dir] != 0} \
# {
#     puts "clean $output_dir"
#     file delete -force {*}[glob -directory $output_dir *];
# }
#
# puts "Clean build"


set need_to_close_project 0

# Check that the right project is open
if {[project_exists ac_psu]} \
{
    project_open -revision top ac_psu
} \
else \
{
    project_new -revision top ac_psu
}
set need_to_close_project 1
#
# read sources
source $project_root/get_vhdl_sources.tcl

set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/main_clocks/main_clocks.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ethernet_clocks_generator/ethernet_clocks_generator.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ddio_in/ethddio_rx.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/ddio_out/ethddio_tx.qip
set_global_assignment -name QIP_FILE $project_root/cyclone_10/IP/ethernet_IP/memory/dual_port_ethernet_ram.qip


foreach x [get_vhdl_sources ../] \
{ \
    if {[lsearch -glob $x *math_library*] == 0} \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x -library math_library
    } \
    elseif {[lsearch -glob $x *cl10_hw_library*] == 0} \
    {
        set_global_assignment -name VHDL_FILE $source_folder/$x -library cl10_hw_library
    }\
    else \
    { \
        set_global_assignment -name VHDL_FILE $source_folder/$x \
    } 
}

source $cyclone_10_tcl_dir/make_assignments.tcl
source $cyclone_10_tcl_dir/set_io_locations.tcl 
    export_assignments 

set_global_assignment -name SDC_FILE $cyclone_10_tcl_dir/ac_inout_constraints.sdc

execute_flow -compile 
