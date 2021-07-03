library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;

entity top is
    port (
        enet_clk_125MHz           : in std_logic;
        ethernet_tx_ddr_clock     : out std_logic;
        pll_input_clock           : in std_logic;
        system_control_FPGA_in    : in system_control_FPGA_input_group;
        system_control_FPGA_out   : out system_control_FPGA_output_group;
        system_control_FPGA_inout : inout system_control_FPGA_inout_record
    );
end entity ;

architecture rtl of top is

    signal system_clocks           : system_clocks_group;
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
    component ethernet_clocks_generator IS
	PORT
	(
		inclk0 : IN STD_LOGIC := '0' ;
		c0     : OUT STD_LOGIC       ;
		c1     : OUT STD_LOGIC       ;
		c2     : OUT STD_LOGIC       ;
		locked : OUT STD_LOGIC
	);
    end component ethernet_clocks_generator;

    signal rx_ddr_clock        : std_logic;
    signal tx_core_clock       : std_logic;
    signal core_clock : std_logic;
    signal pll_locked : std_logic;

------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    u_main_clocks : main_clocks
    port map( areset => '0'                         ,
              inclk0 => pll_input_clock             ,
              c0     => core_clock ,
              locked => pll_locked);

------------------------------------------------------------------------
    u_ethernet_clocks : ethernet_clocks_generator
	port map
	(
		inclk0  => enet_clk_125MHz       ,
		c0      => rx_ddr_clock          ,
		c1      => ethernet_tx_ddr_clock ,
		c2      => tx_core_clock         ,
		locked  => open
	);

------------------------------------------------------------------------
    system_clocks <= (core_clock           => core_clock   ,
                     pll_locked            => pll_locked   ,
                     ethernet_rx_ddr_clock => rx_ddr_clock ,
                     ethernet_tx_ddr_clock => tx_core_clock
                     );

    u_system_control : system_control
    port map( system_clocks             ,
              system_control_FPGA_in    ,
              system_control_FPGA_out   ,
              system_control_FPGA_inout ,
              system_control_data_in    ,
              system_control_data_out);

end rtl;
