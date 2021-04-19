library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.power_supply_control_pkg.all;

entity power_supply_control is
    port (
        power_supply_control_clocks   : in power_supply_control_clock_group;
        power_supply_control_FPGA_in  : in power_supply_control_FPGA_input_group;
        power_supply_control_FPGA_out : out power_supply_control_FPGA_output_group;
        power_supply_control_data_in  : in power_supply_control_data_input_group;
        power_supply_control_data_out : out power_supply_control_data_output_group
    );
end entity power_supply_control;

architecture rtl of power_supply_control is


begin



end rtl;
