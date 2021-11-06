echo off
set source=source/

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/sincos/sincos_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_internal_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg.vhd
ghdl -a --ieee=synopsys %source%/math_library/division/division_pkg.vhd
rem ghdl -a --ieee=synopsys --work=math_library %source%/math_library/division/division_pkg_body.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/first_order_filter/first_order_filter_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/pi_controller/pi_controller_pkg.vhd

ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/state_variable/state_variable_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/lcr_filter_model/lcr_filter_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/inverter_model/inverter_model_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/power_supply_model/psu_inverter_simulation_models_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/dynamic_simulation_library/power_supply_model/power_supply_simulation_model_pkg.vhd

ghdl -a --ieee=synopsys %source%/spi/spi_pkg.vhd
ghdl -a --ieee=synopsys %source%/spi/spi_adc_pkg.vhd

ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_clocks_pkg.vhd 
ghdl -a --ieee=synopsys %source%/system_clocks_pkg.vhd

        ghdl -a --ieee=synopsys %source%/adc_interface/spi_sar_adc/spi_sar_adc_pkg.vhd 

            ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
        ghdl -a --ieee=synopsys %source%/uart/uart_transreceiver/uart_transreceiver_pkg.vhd
    ghdl -a --ieee=synopsys %source%/uart/uart_pkg.vhd

                    ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/mdio_driver/mdio_three_state_io_driver/mdio_three_state_io_driver_pkg.vhd
                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/mdio_driver/mdio_driver_pkg.vhd
                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/mdio_driver/mdio_driver_internal_pkg.vhd
                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/mdio_driver/mmd_access_functions_pkg.vhd

            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/PCK_CRC_32_D8.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_read_pkg.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_write_pkg.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_pkg.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/arch_cl10_ethernet_frame_ram.vhd 
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_common/dual_port_ethernet_ram/arch_cl10_ethernet_frame_transmit.vhd 

            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/network_protocol_header_pkg.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/network_protocol.vhd

            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/transport_layer/user_datagram_protocol/arch_user_datagram_protocol.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/internet_layer/internet_protocol/arch_internet_protocol.vhd 

            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/link_layer/ethernet_protocol/ethernet_protocol_internal_pkg.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/network_protocol_stack/link_layer/ethernet_protocol/arch_ethernet_protocol.vhd

                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio_pkg.vhd
                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_pkg.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_internal_pkg.vhd

                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio_pkg.vhd
                ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_frame_transmitter_pkg.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_transmit_fifo_pkg.vhd
            ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_frame_transmit_controller_pkg.vhd

        ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet/ethernet_pkg.vhd
    ghdl -a --ieee=synopsys %source%/ethernet_communication/ethernet_communication_pkg.vhd

            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_hardware/power_supply_control/gate_drive_power/gate_drive_power_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_hardware/power_supply_control/gate_drive_power/gate_drive_power_internal_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_hardware/power_supply_control/power_supply_control_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_hardware/power_supply_hardware_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_hardware/power_supply_hardware.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/system_components_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/system_components.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_pkg.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_internal_pkg.vhd


