library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.gate_drive_power_pkg.all;

package gate_drive_power_internal_pkg is


------------------------------------------------------------------------
    procedure force_all_gate_drivers_off (
        signal gate_drive_power_FPGA_output : out gate_drive_power_FPGA_output_group);
------------------------------------------------------------------------
    function gate_drive_powers_are_turned_on ( gate_drive_power_input : gate_drive_power_data_input_group)
        return boolean;
------------------------------------------------------------------------
    function gate_drive_powers_are_turned_off ( gate_drive_power_input : gate_drive_power_data_input_group)
        return boolean;

------------------------------------------------------------------------
end package gate_drive_power_internal_pkg;


package body gate_drive_power_internal_pkg is

------------------------------------------------------------------------
    procedure force_all_gate_drivers_off
    (
        signal gate_drive_power_FPGA_output : out gate_drive_power_FPGA_output_group
    ) is
    begin
        for i in gate_drive_pwm_output_array'left to gate_drive_pwm_output_array'right loop
            gate_drive_power_FPGA_output.gate_drive_power_pwm_output(i) <= '0';
        end loop;
        
    end force_all_gate_drivers_off;
------------------------------------------------------------------------
    function gate_drive_powers_are_turned_on
    (
        gate_drive_power_input : gate_drive_power_data_input_group
    )
    return boolean
    is
    begin
        return gate_drive_power_input.gate_driver_powers_are_started;
    end gate_drive_powers_are_turned_on;

------------------------------------------------------------------------
    function gate_drive_powers_are_turned_off
    (
        gate_drive_power_input : gate_drive_power_data_input_group
    )
    return boolean
    is
    begin
        return not gate_drive_power_input.gate_driver_powers_are_started;
    end gate_drive_powers_are_turned_off;

------------------------------------------------------------------------
end package body gate_drive_power_internal_pkg;

