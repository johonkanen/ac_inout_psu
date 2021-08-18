rem simulate lcr_model.vhd
echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
set source= %project_root%/source

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/state_variable/state_variable_pkg.vhd
ghdl -a --ieee=synopsys lrc_model.vhd
ghdl -e --ieee=synopsys lrc_model
ghdl -r --ieee=synopsys lrc_model --vcd=lrc_model.vcd 

IF %1 EQU 1 start "" gtkwave lrc_model.vcd
