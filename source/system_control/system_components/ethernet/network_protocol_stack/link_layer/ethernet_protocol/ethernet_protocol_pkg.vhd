library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package ethernet_protocol_pkg is

    type ethernet_protocol_clock_group is record
        clock : std_logic;
    end record;
    
    type ethernet_protocol_data_input_group is record
        frame_ram_output         : ram_read_output_group;
        toggle_frame_is_received : std_logic;
    end record;
    
    type ethernet_protocol_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
    end record;
    
    component ethernet_protocol is
        port (
            ethernet_protocol_clocks   : in ethernet_protocol_clock_group;
            ethernet_protocol_data_in  : in ethernet_protocol_data_input_group;
            ethernet_protocol_data_out : out ethernet_protocol_data_output_group
        );
    end component ethernet_protocol;
    
    -- signal ethernet_protocol_clocks   : ethernet_protocol_clock_group;
    -- signal ethernet_protocol_data_in  : ethernet_protocol_data_input_group;
    -- signal ethernet_protocol_data_out : ethernet_protocol_data_output_group
    
    -- u_ethernet_protocol : ethernet_protocol
    -- port map( ethernet_protocol_clocks,
    --	  ethernet_protocol_data_in,
    --	  ethernet_protocol_data_out); 

end package ethernet_protocol_pkg; 
