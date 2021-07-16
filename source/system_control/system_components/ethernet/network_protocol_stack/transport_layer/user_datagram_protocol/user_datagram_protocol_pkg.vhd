library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package user_datagram_protocol_pkg is

    type user_datagram_protocol_clock_group is record
        clock : std_logic;
    end record;
    
    type user_datagram_protocol_data_input_group is record
        frame_ram_output : ram_read_output_group;
        frame_is_received : boolean;
    end record;
    
    type user_datagram_protocol_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
    end record;
    
    component user_datagram_protocol is
        port (
            user_datagram_protocol_clocks : in user_datagram_protocol_clock_group; 
            user_datagram_protocol_data_in : in user_datagram_protocol_data_input_group;
            user_datagram_protocol_data_out : out user_datagram_protocol_data_output_group
        );
    end component user_datagram_protocol;
    
    -- signal user_datagram_protocol_clocks   : user_datagram_protocol_clock_group;
    -- signal user_datagram_protocol_data_in  : user_datagram_protocol_data_input_group;
    -- signal user_datagram_protocol_data_out : user_datagram_protocol_data_output_group
    
    -- u_user_datagram_protocol : user_datagram_protocol
    -- port map( user_datagram_protocol_clocks,
    --	  user_datagram_protocol_data_in,
    --	  user_datagram_protocol_data_out);
    

end package user_datagram_protocol_pkg; 
