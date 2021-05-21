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
    procedure stop_gate_drive_powers (
        signal system_components_input : out system_components_data_input_group);

------------------------------------------------------------------------
end package system_control_internal_pkg;
