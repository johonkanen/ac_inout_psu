library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package system_clocks_pkg is

    type system_clocks_input_group is record
        clock : std_logic;
    end record;

    type ethernet_clocks_group is record
        data : std_logic;
    end record;

    type system_clocks_group is record
        core_clock      : std_logic;
        pll_locked      : std_logic;
    end record;
    
    component system_clocks is
        port (
            system_clocks_input : in system_clocks_input_group; 
            system_clocks : out system_clocks_group
        );
    end component system_clocks;
    
    -- signal system_clocks_input : system_clocks_input_group; 
    -- signal system_clocks : system_clocks_group; 
    
    -- u_system_clocks_pkg : system_clocks_pkg
    -- port map( 
            -- system_clocks_input,
            -- system_clocks);
    

end package system_clocks_pkg;

