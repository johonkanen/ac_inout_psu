library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package internet_protocol_pkg is

    type internet_protocol_clock_group is record
        clock : std_logic;
    end record;
    
    type internet_protocol_data_input_group is record
        frame_ram_output : ram_read_output_group;
        frame_is_received : boolean;
    end record;
    
    type internet_protocol_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
    end record;
    
    component internet_protocol is
        port (
            internet_protocol_clocks : in internet_protocol_clock_group; 
            internet_protocol_data_in : in internet_protocol_data_input_group;
            internet_protocol_data_out : out internet_protocol_data_output_group
        );
    end component internet_protocol;
    
    -- signal internet_protocol_clocks   : internet_protocol_clock_group;
    -- signal internet_protocol_data_in  : internet_protocol_data_input_group;
    -- signal internet_protocol_data_out : internet_protocol_data_output_group
    
    -- u_internet_protocol : internet_protocol
    -- port map( internet_protocol_clocks,
    --	  internet_protocol_data_in,
    --	  internet_protocol_data_out);
    

end package internet_protocol_pkg; 
