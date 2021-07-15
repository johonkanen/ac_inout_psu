library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package protocol_stack_pkg is

    type protocol_stack_clock_group is record
        core_clock : std_logic;
    end record;
    
    type protocol_stack_data_input_group is record
        frame_ram_output : ram_read_output_group;
        frame_is_received : boolean;
    end record;
    
    type protocol_stack_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
    end record;
    
    component protocol_stack is
        port (
            protocol_stack_clocks : in protocol_stack_clock_group; 
            protocol_stack_data_in : in protocol_stack_data_input_group;
            protocol_stack_data_out : out protocol_stack_data_output_group
        );
    end component protocol_stack;
    
    -- signal protocol_stack_clocks   : protocol_stack_clock_group;
    -- signal protocol_stack_data_in  : protocol_stack_data_input_group;
    -- signal protocol_stack_data_out : protocol_stack_data_output_group;
    
    -- u_protocol_stack : protocol_stack
    -- port map( protocol_stack_clocks,
    --	  protocol_stack_data_in,
    --	  protocol_stack_data_out);

end package protocol_stack_pkg;
