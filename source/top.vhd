library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_control_pkg.all;

entity top is
    port (
        enet_clk_125MHz         : in std_logic;
        pll_input_clock         : in std_logic;
        system_control_FPGA_in  : in system_control_FPGA_input_group;
        system_control_FPGA_out : out system_control_FPGA_output_group;
        system_control_FPGA_inout : inout system_control_FPGA_inout_record
    );
end entity ;

architecture rtl of top is

    signal system_control_clocks   : system_control_clock_group;
    signal system_control_data_in  : system_control_data_input_group;
    signal system_control_data_out : system_control_data_output_group;

------------------------------------------------------------------------
    component main_clocks IS
        PORT
        (
            areset : IN STD_LOGIC := '0' ;
            inclk0 : IN STD_LOGIC := '0' ;
            c0     : OUT STD_LOGIC       ;
            locked : OUT STD_LOGIC
        );
    END component main_clocks;

------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    u_main_clocks : main_clocks
    port map( areset => '0'                         ,
              inclk0 => pll_input_clock             ,
              c0     => system_control_clocks.clock ,
              locked => system_control_clocks.reset_n);

------------------------------------------------------------------------
    u_system_control : system_control
    port map( system_control_clocks ,
    	  system_control_FPGA_in    ,
    	  system_control_FPGA_out   ,
    	  system_control_FPGA_inout ,
    	  system_control_data_in    ,
    	  system_control_data_out);

end rtl;
