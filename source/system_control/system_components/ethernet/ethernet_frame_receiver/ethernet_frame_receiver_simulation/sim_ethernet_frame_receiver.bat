rem simulate ethernet_frame_receiver.vhd
echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

ghdl -a --ieee=synopsys ..\ethernet_frame_receiver_pkg.vhd
ghdl -a --ieee=synopsys ..\ethernet_frame_receiver.vhd
ghdl -a --ieee=synopsys tb_ethernet_frame_receiver.vhd
ghdl -e --ieee=synopsys tb_ethernet_frame_receiver
ghdl -r --ieee=synopsys tb_ethernet_frame_receiver --vcd=tb_ethernet_frame_receiver.vcd


IF %1 EQU 1 start "" gtkwave tb_ethernet_frame_receiver.vcd
