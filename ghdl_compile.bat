echo off
set source=source/

ghdl -a --ieee=synopsys --work=math_library %source%/math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --work=math_library %source%/math_library/first_order_filter/first_order_filter_pkg.vhd

ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_clocks_pkg.vhd 
ghdl -a --ieee=synopsys %source%/system_clocks_pkg.vhd

        ghdl -a --ieee=synopsys %source%/system_control/system_components/adc_interface/spi_sar_adc/spi_sar_adc_pkg.vhd 

            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_transreceiver_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_pkg.vhd

                ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/mdio_driver/mdio_three_state_io_driver/mdio_three_state_io_driver_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/mdio_driver/mdio_driver_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/mdio_driver/mdio_driver_internal_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/mdio_driver/mmd_access_functions_pkg.vhd

            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_common/PCK_CRC_32_D8.vhd 

            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_receiver/ethernet_rx_ddio/ethernet_rx_ddio.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_receiver/ethernet_frame_receiver_internal_pkg.vhd

            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_transmitter/ethernet_tx_ddio/ethernet_tx_ddio.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_transmitter/ethernet_frame_transmitter_pkg.vhd
        rem ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_frame_transmitter/ethernet_frame_transmitter_internal_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/ethernet/ethernet_pkg.vhd

            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_internal_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/power_supply_control_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/system_components_pkg.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_pkg.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_internal_pkg.vhd


