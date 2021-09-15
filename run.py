from pathlib import Path
from os.path import join
from vunit import VUnit
from glob import glob

# ROOT
ROOT = Path(__file__).resolve().parent

# Sources path for DUT
SRC_PATH = ROOT / "source" 
MATH_LIBRARY_PATH = "math_library"
SYSTEM_CONTROL_PATH = "system_control"

VU = VUnit.from_argv()

mathlib = VU.add_library("math_library")

lib = VU.add_library("lib")

## Possible single line VHDL source code detection with globbing 
## Uncomment all subsequent lines if glob is used
# lib.add_source_files(glob("source/**/*/*.vhd", rursive=True)) 



lib.add_source_files(SRC_PATH / "*.vhd") 

mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "first_order_filter" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "multiplier" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "lcr_filter_model" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "state_variable" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "pi_controller" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "inverter_model" / "*.vhd") 
mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "power_supply_model" / "*.vhd") 

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "adc_interface" / "spi_sar_adc" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "gate_drive_power" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "uart_rx" /"*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "uart_tx" /"*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "mdio_driver" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "mdio_driver" / "mdio_three_state_io_driver" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet_common" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet_common" / "dual_port_ethernet_ram" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "internet_layer" / "internet_protocol" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "link_layer" / "ethernet_protocol" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "transport_layer" / "user_datagram_protocol" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "ethernet_rx_ddio" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "ethernet_frame_transmit*_pkg.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "ethernet_tx_ddio" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "gate_drive_power" / "*.vhd")


VU.main()
