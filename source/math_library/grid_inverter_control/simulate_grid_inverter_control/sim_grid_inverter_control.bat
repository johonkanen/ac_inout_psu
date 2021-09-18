echo off
rem simulate grid_inverter_control.vhd

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/sincos/sincos_pkg.vhd

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/state_variable/state_variable_pkg.vhd 
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/pi_controller/pi_controller_pkg.vhd

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_internal_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg_body.vhd

ghdl -a --ieee=synopsys tb_grid_inverter_control.vhd
ghdl -e --ieee=synopsys tb_grid_inverter_control
ghdl -r --ieee=synopsys tb_grid_inverter_control --vcd=tb_grid_inverter_control.vcd


IF %1 EQU 1 start "" gtkwave tb_grid_inverter_control.vcd
