library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_control_pkg.all;

entity top is
    port (
        enet_clk_125MHz             : std_logic;
        pll_input_clock             : std_logic
        system_control_pkg_FPGA_in  : system_control_pkg_FPGA_input_group;
        system_control_pkg_FPGA_out : system_control_pkg_FPGA_output_group
    );
end entity ;

architecture rtl of top is

    signal system_control_pkg_clocks   : system_control_pkg_clock_group;
    signal system_control_pkg_data_in  : system_control_pkg_data_input_group;
    signal system_control_pkg_data_out : system_control_pkg_data_output_group

begin

------------------------------------------------------------------------
    u_system_control : system_control
    port map( system_control_clocks,
    	  system_control_FPGA_in,
    	  system_control_FPGA_out,
    	  system_control_data_in,
    	  system_control_data_out);



end rtl;
