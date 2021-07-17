library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package internet_protocol_pkg is

    type internet_protocol_clock_group is record
        clock : std_logic;
    end record;

    type protocol_control_record is record
        protocol_processing_is_requested : boolean;
        protocol_start_address : natural;
    end record;
    
    type internet_protocol_data_input_group is record
        frame_ram_output : ram_read_output_group;
        protocol_control : protocol_control_record; 
    end record;
    
    type internet_protocol_data_output_group is record
        frame_ram_read_control : ram_read_control_group;
        ram_offset : natural;
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

------------------------------------------------------------------------
    procedure request_protocol_processing (
        signal control : out protocol_control_record;
        protocol_start_address : natural);
    
    procedure init_protocol_control (
        signal control : out protocol_control_record);
------------------------------------------------------------------------ 
end package internet_protocol_pkg; 

package body internet_protocol_pkg is

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

end package body internet_protocol_pkg;
