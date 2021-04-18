library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_control_pkg.all;
    use work.system_components_pkg.all;

entity system_control is
    port (
        system_control_clocks   : in system_control_clock_group;
        system_control_FPGA_in  : in system_control_FPGA_input_group;
        system_control_FPGA_out : out system_control_FPGA_output_group;
        system_control_data_in  : in system_control_data_input_group;
        system_control_data_out : out system_control_data_output_group
    );
end entity system_control;
    

architecture rtl of system_control is

    signal system_components_clocks   : system_components_clock_group;
    signal system_components_data_in  : system_components_data_input_group;
    signal system_components_data_out : system_components_data_output_group;
    
begin

------------------------------------------------------------------------
    u_system_components : system_components
    port map( system_components_clocks,
    	  system_control_FPGA_in.system_components_FPGA_in,
    	  system_control_FPGA_out.system_components_FPGA_out,
    	  system_components_data_in,
    	  system_components_data_out);

end rtl;
