package require ::quartus::project
package require ::quartus::flow
package require cmdline


# set options \
# {\
#     # { "source_path.arg"} \
#     # { "load_program_to.arg"} \
#     # { "usb_cable.arg"} \
# }
#
# array set opts [::cmdline::getoptions quartus(args) $options]
#
variable cyclone_10_tcl_dir [ file dirname [ file normalize [ info script ] ] ]
# set tcl_scripts $opts(source_path)
set project_root $cyclone_10_tcl_dir/../../
set source_folder $project_root/../../source
set fpga_device 10CL025YU256I7G

set need_to_close_project 0

# Check that the right project is open
	if {[project_exists ac_psu]} \
    {
		project_open -revision jee ac_psu
	} \
    else \
    {
		project_new -revision jee ac_psu
	}
	set need_to_close_project 1

    #
# read sources
source $project_root/get_vhdl_sources.tcl

