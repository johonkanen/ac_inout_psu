rem simulate ethernet_frame_transmitter.vhd
rem
set ethernet_mac_source=../../

echo off
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%..\ethernet_clocks_pkg.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%..\ethernet_frame_definitions_pkg.vhd

ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_tx_ddio\ethernet_tx_ddio_pkg.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_tx_ddio\ethernet_tx_ddio.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_tx_ddio\arch_simulation_tx_ddio.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_frame_transmitter_pkg.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_frame_transmitter_internal_pkg.vhd
ghdl -a --std=08 --ieee=synopsys %ethernet_mac_source%\ethernet_frame_transmitter\ethernet_frame_transmitter.vhd

ghdl -a --std=08 --ieee=synopsys tb_ethernet_frame_transmitter.vhd
ghdl -e --std=08 --ieee=synopsys tb_ethernet_frame_transmitter
ghdl -r --std=08 --ieee=synopsys tb_ethernet_frame_transmitter --vcd=tb_ethernet_frame_transmitter.vcd


IF %1 EQU 1 start "" gtkwave tb_ethernet_frame_transmitter.vcd
