library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package system_clocks_pkg is

    type system_clocks_group is record
        core_clock            : std_logic;
        pll_locked            : std_logic;
        ethernet_rx_ddr_clock : std_logic;
        ethernet_tx_ddr_clock : std_logic;
    end record;
    
end package system_clocks_pkg;
