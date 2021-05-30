echo off
set source=source/

        ghdl -a --ieee=synopsys %source%/system_control/system_components/adc_interface/spi_sar_adc/spi_sar_adc_pkg.vhd 
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_transreceiver_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_pkg.vhd
    rem ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart.vhd

            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_internal_pkg.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/power_supply_control/power_supply_control_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/system_components_pkg.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_pkg.vhd
ghdl -a --ieee=synopsys %source%/system_control/system_control_internal_pkg.vhd
