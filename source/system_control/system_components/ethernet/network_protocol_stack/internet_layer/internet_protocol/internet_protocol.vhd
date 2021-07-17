library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- entity network_protocol is
--     port (
--         network_protocol_clocks   : in network_protocol_clock_group;
--         network_protocol_data_in  : in network_protocol_data_input_group;
--         network_protocol_data_out : out network_protocol_data_output_group
--     );
-- end entity network_protocol;

architecture internet_protocol of network_protocol is

    alias clock is network_protocol_clocks.clock;
    alias internet_protocol_data_in is network_protocol_data_in;
    alias internet_protocol_data_out is network_protocol_data_out;
    alias protocol_control is internet_protocol_data_in.protocol_control; 

    signal frame_ram_read_control_port : ram_read_control_group;
    signal shift_register : std_logic_vector(31 downto 0);
    signal ram_read_controller : ram_reader;
    signal ram_offset : natural range 0 to 2**11-1;
    signal header_offset : natural range 0 to 2**11-1;

begin

------------------------------------------------------------------------
    route_data_out : process(frame_ram_read_control_port, ram_offset) 
    begin
        internet_protocol_data_out <= (
                                          frame_ram_read_control => frame_ram_read_control_port,
                                          ram_offset => ram_offset
                                      );

    end process route_data_out;	
------------------------------------------------------------------------

    ip_header_processor : process(clock)
        
    begin
        if rising_edge(clock) then
            create_ram_read_controller(frame_ram_read_control_port, internet_protocol_data_in.frame_ram_output, ram_read_controller, shift_register); 

            if protocol_control.protocol_processing_is_requested then
                header_offset <= protocol_control.protocol_start_address;
            end if;

                if get_ram_address(internet_protocol_data_in.frame_ram_output) = header_offset+8 then
                    if shift_register(7 downto 0) = x"11" then
                        ram_offset <= 14 + 8;
                    else
                        ram_offset <= 0;
                    end if;
                end if;

        end if; --rising_edge
    end process ip_header_processor;	

end internet_protocol;
