library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package system_components_pkg is

    type system_components_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type system_components_FPGA_input_group is record
        clock : std_logic;
    end record;
    
    type system_components_FPGA_output_group is record
        clock : std_logic;
    end record;
    
    type system_components_data_input_group is record
        clock : std_logic;
    end record;
    
    type system_components_data_output_group is record
        clock : std_logic;
    end record;
    
    component system_components is
        port (
            system_components_clocks : in system_components_clock_group; 
            system_components_FPGA_in : in system_components_FPGA_input_group;
            system_components_FPGA_out : out system_components_FPGA_output_group; 
            system_components_data_in : in system_components_data_input_group;
            system_components_data_out : out system_components_data_output_group
        );
    end component system_components;
    
    -- signal system_components_clocks   : system_components_clock_group;
    -- signal system_components_FPGA_in  : system_components_FPGA_input_group;
    -- signal system_components_FPGA_out : system_components_FPGA_output_group;
    -- signal system_components_data_in  : system_components_data_input_group;
    -- signal system_components_data_out : system_components_data_output_group
    
    -- u_system_components : system_components
    -- port map( system_components_clocks,
    -- 	  system_components_FPGA_in,
    --	  system_components_FPGA_out,
    --	  system_components_data_in,
    --	  system_components_data_out);
    

------------------------------------------------------------------------
end package system_components_pkg;

------------------------------------------------------------------------
package body system_components_pkg is

------------------------------------------------------------------------
end package body system_components_pkg;
