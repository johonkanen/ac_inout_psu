library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_components_pkg.all;
    use work.power_supply_control_pkg.all;

entity system_components is
    port (
        system_components_clocks : in system_components_clock_group; 
        system_components_FPGA_in : in system_components_FPGA_input_group;
        system_components_FPGA_out : out system_components_FPGA_output_group; 
        system_components_data_in : in system_components_data_input_group;
        system_components_data_out : out system_components_data_output_group
    );
end entity system_components;

architecture rtl of system_components is

    signal power_supply_control_clocks   : power_supply_control_clock_group;
    signal power_supply_control_data_in  : power_supply_control_data_input_group;
    signal power_supply_control_data_out : power_supply_control_data_output_group;
    

begin

    u_power_supply_control : power_supply_control
    port map( power_supply_control_clocks,
    	  system_components_FPGA_in.power_supply_control_FPGA_in,
    	  system_components_FPGA_out.power_supply_control_FPGA_out,
    	  power_supply_control_data_in,
    	  power_supply_control_data_out);


end rtl;
