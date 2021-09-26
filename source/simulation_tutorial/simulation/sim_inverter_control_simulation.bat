rem simulate output_inverter.vhd
echo off
 
echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source
 
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/sincos/sincos_pkg.vhd
 
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/state_variable/state_variable_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/lcr_filter_model/lcr_filter_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/pi_controller/pi_controller_pkg.vhd 
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/inverter_model/inverter_model_pkg.vhd
 
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_internal_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg_body.vhd
 
ghdl -a --ieee=synopsys tb_inverter_control_simulation.vhd
ghdl -e --ieee=synopsys tb_inverter_control_simulation
ghdl -r --ieee=synopsys tb_inverter_control_simulation --vcd=tb_inverter_control_simulation.vcd
 
 
IF %1 EQU 1 start "" gtkwave tb_inverter_control_simulation.vcd
