library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_components_pkg.all;

package system_control_internal_pkg is

------------------------------------------------------------------------
    procedure start_gate_drive_powers (
        signal system_components_input : out system_components_data_input_group);

------------------------------------------------------------------------
end package system_control_internal_pkg;

package body system_control_internal_pkg is

------------------------------------------------------------------------
    procedure start_gate_drive_powers
    (
        signal system_components_input : out system_components_data_input_group
    ) is
        use work.gate_drive_power_pkg.all;
        alias gate_drive_power_input is system_components_input.power_supply_control_data_in.gate_drive_power_data_in;
    begin 
        start_gate_drive_powers(gate_drive_power_input);
    end start_gate_drive_powers;

------------------------------------------------------------------------
end package body system_control_internal_pkg; 
