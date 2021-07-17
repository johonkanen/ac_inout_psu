library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package network_protocol_header_pkg is 

    type network_protocol_clock_group is record
        clock : std_logic;
    end record;

    type protocol_control_record is record
        protocol_processing_is_requested : boolean;
        protocol_start_address : natural;
    end record;
    
    type network_protocol_data_input_group is record
        frame_ram_output : ram_read_output_group;
        protocol_control : protocol_control_record; 
    end record;
    
    type network_protocol_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
        ram_offset : natural;
    end record;
    
    component network_protocol is
        port (
            network_protocol_clocks : in network_protocol_clock_group; 
            network_protocol_data_in : in network_protocol_data_input_group;
            network_protocol_data_out : out network_protocol_data_output_group
        );
    end component network_protocol;
    
    -- signal network_protocol_clocks   : network_protocol_clock_group;
    -- signal network_protocol_data_in  : network_protocol_data_input_group;
    -- signal network_protocol_data_out : network_protocol_data_output_group
    
    -- u_network_protocol : network_protocol
    -- port map( network_protocol_clocks,
    --	  network_protocol_data_in,
    --	  network_protocol_data_out);

------------------------------------------------------------------------
    procedure request_protocol_processing (
        signal control : out protocol_control_record;
        protocol_start_address : natural);
    
    procedure init_protocol_control (
        signal control : out protocol_control_record);
------------------------------------------------------------------------ 
end package network_protocol_header_pkg;

package body network_protocol_header_pkg is



------------------------------------------------------------------------
    procedure init_protocol_control
    (
        signal control : out protocol_control_record
    ) is
    begin
        control.protocol_processing_is_requested <= false;
        control.protocol_start_address <= 0;
    end init_protocol_control; 

------------------------------------------------------------------------
    procedure request_protocol_processing
    (
        signal control : out protocol_control_record;
        protocol_start_address : natural
    ) is
    begin
        control.protocol_processing_is_requested <= true;
        control.protocol_start_address <= protocol_start_address;
        
    end request_protocol_processing;

------------------------------------------------------------------------
end package body network_protocol_header_pkg;
