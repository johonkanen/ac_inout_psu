# ac input/output power supply
A vhdl implementation for a 3kW single phase input/output power supply control and communications. Power supply has gigabit ethernet and uart communications.
Hardware test code currently developed in source/system_control/system_components/system_components.vhd

There is a run_ghdl_testbenches.bat file that can be run on console to trigger testbenches.

A companion website with some descriptions on the project can be found at
https://hardwaredescriptions.com

A tutorial on how to use the code and install ghdl/gtkwave is currently being written at
https://hardwaredescriptions.com/getting-started-with-fpga-and-vhdl-step-by-step-guide-from-tool-installation-to-your-first-inverter-control/

The steps to produce the uart console programs for testing the VHDL are found in https://hardwaredescriptions.com/?page_id=912

system sources are in ./get_vhdl_sources.tcl file in reverse order compared to the code architecture. This is done to ease maintaining ghdl_compile.bat which is used for syntax checking and simulation

Currently compiled with quartus software and for cyclone 10lp025. Build can be started with call to quartus shell and the top level tcl script is in /cyclone_10/tcl/build_project.tcl

.gitignore includes ./compile folder in which project can be compiled using

 quartus_sh -t ..\cyclone_10\tcl\build_project.tcl
 
 after build, the code can be uploaded to FPGA using 
 quartus_pgm -c "USB-Blaster [USB-0]" -m JTAG -o "p;./output/top.sof"
 
 The repository folder structure follows the code architecture
 
    top -- physical mapping layer
      system_control -- high level system control functions like power sequencing
        system_components -- interconnect for top level module interfaces
            ad_interface,
            uart,
            ethernet,
            (lcd),
            (power_supply_control)
