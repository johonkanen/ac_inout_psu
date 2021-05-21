proc get_vhdl_sources {void}\
{ 
    return \
    { 
                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_pkg.vhd
                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power_internal_pkg.vhd
                        /system_control/system_components/power_supply_control/gate_drive_power/gate_drive_power.vhd

                    /system_control/system_components/power_supply_control/power_supply_control_pkg.vhd
                    /system_control/system_components/power_supply_control/power_supply_control.vhd

                        /system_control/system_components/uart/uart_transreceiver/uart_tx.vhd
                        /system_control/system_components/uart/uart_transreceiver/uart_rx.vhd
                        /system_control/system_components/uart/uart_transreceiver/uart_transreceiver.vhd

                    /system_control/system_components/uart/uart_pkg.vhd
                    /system_control/system_components/uart/uart.vhd

                /system_control/system_components/system_components_pkg.vhd
                /system_control/system_components/system_components.vhd

            /system_control/system_control_pkg.vhd
            /system_control/system_control_internal_pkg.vhd
            /system_control/system_control_internal_body.vhd
            /system_control/system_control.vhd

        top.vhd 
    } 
}
