proc get_vhdl_sources {void}\
{ 
    return \
    { 
        /math_library/multiplier/multiplier_pkg.vhd
        /math_library/sincos/sincos_pkg.vhd
        /math_library/division/division_internal_pkg.vhd
        /math_library/division/division_pkg.vhd
        /math_library/division/division_pkg_body.vhd
        /math_library/first_order_filter/first_order_filter_pkg.vhd
        /math_library/state_variable/state_variable_pkg.vhd
        /math_library/lcr_filter_model/lcr_filter_model_pkg.vhd
        /math_library/pi_controller/pi_controller_pkg.vhd
        /math_library/inverter_model/inverter_model_pkg.vhd
        /math_library/power_supply_model/psu_inverter_simulation_models_pkg.vhd
        /math_library/power_supply_model/power_supply_simulation_model_pkg.vhd

        /system_clocks_pkg.vhd

                                    /ethernet_communication/ethernet/mdio_driver/mdio_three_state_io_driver/mdio_three_state_io_driver_pkg.vhd
                                    /ethernet_communication/ethernet/mdio_driver/mdio_three_state_io_driver/mdio_three_state_io_driver.vhd
                                /ethernet_communication/ethernet/mdio_driver/mdio_driver_pkg.vhd
                                /ethernet_communication/ethernet/mdio_driver/mdio_driver_internal_pkg.vhd
                                /ethernet_communication/ethernet/mdio_driver/mdio_driver.vhd
                            /ethernet_communication/ethernet/mdio_driver/mmd_access_functions_pkg.vhd 

                        ethernet_communication/ethernet/ethernet_clocks_pkg.vhd 
                                /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio_pkg.vhd
                                /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio.vhd
                                /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/arch_cl10_rx_ddio.vhd
                            /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_pkg.vhd
                            /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_internal_pkg.vhd
                            /ethernet_communication/ethernet/ethernet_frame_receiver/ethernet_frame_receiver.vhd


                        /ethernet_communication/ethernet_common/PCK_CRC_32_D8.vhd
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_read_pkg.vhd 
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_write_pkg.vhd 
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram_pkg.vhd 
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/ethernet_frame_ram.vhd 
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/arch_cl10_ethernet_frame_ram.vhd 
                        /ethernet_communication/ethernet_common/dual_port_ethernet_ram/arch_cl10_ethernet_frame_transmit.vhd 

                /ethernet_communication/network_protocol_stack/network_protocol_header_pkg.vhd
                /ethernet_communication/network_protocol_stack/network_protocol.vhd

                    /ethernet_communication/network_protocol_stack/transport_layer/user_datagram_protocol/arch_user_datagram_protocol.vhd 
                    /ethernet_communication/network_protocol_stack/internet_layer/internet_protocol/arch_internet_protocol.vhd

                    /ethernet_communication/network_protocol_stack/link_layer/ethernet_protocol/ethernet_protocol_internal_pkg.vhd
                    /ethernet_communication/network_protocol_stack/link_layer/ethernet_protocol/arch_ethernet_protocol.vhd

                                /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio_pkg.vhd
                                /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio.vhd
                                /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/arch_cl10_tx_ddio.vhd
                            /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_frame_transmitter_pkg.vhd
                            /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_transmit_fifo_pkg.vhd
                            /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_frame_transmit_controller_pkg.vhd
                            /ethernet_communication/ethernet/ethernet_frame_transmitter/ethernet_frame_transmitter.vhd

                        /ethernet_communication/ethernet/ethernet_pkg.vhd
                        /ethernet_communication/ethernet/ethernet.vhd

            /ethernet_communication/ethernet_communication_pkg.vhd
            /ethernet_communication/ethernet_communication.vhd

                    /uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
                    /uart/uart_transreceiver/uart_tx/uart_tx.vhd
                    /uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
                    /uart/uart_transreceiver/uart_rx/uart_rx.vhd
                /uart/uart_transreceiver/uart_transreceiver_pkg.vhd
                /uart/uart_transreceiver/uart_transreceiver.vhd

            /uart/uart_pkg.vhd
            /uart/uart.vhd


                    /system_control/system_components/adc_interface/spi_sar_adc/spi_sar_adc_pkg.vhd 
                    /system_control/system_components/adc_interface/spi_sar_adc/ads7056_driver.vhd 

                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_pkg.vhd
                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_internal_pkg.vhd
                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power.vhd

                    /system_control/system_components/power_supply_control/power_supply_control_pkg.vhd
                    /system_control/system_components/power_supply_control/power_supply_control.vhd

                /system_control/system_components/system_components_pkg.vhd
                /system_control/system_components/arch_hack_test_system_components.vhd 
                /system_control/system_components/system_components.vhd

            /system_control/system_control_pkg.vhd
            /system_control/system_control_internal_pkg.vhd
            /system_control/system_control_internal_body.vhd
            /system_control/system_control.vhd

        top.vhd 
    } 
}
