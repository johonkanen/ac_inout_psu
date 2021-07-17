library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;
    use work.ethernet_protocol_pkg.all; 
    use work.ethernet_protocol_internal_pkg.all; 
    use work.internet_protocol_pkg.all; 

entity ethernet_protocol is
    port (
        ethernet_protocol_clocks   : in ethernet_protocol_clock_group;
        ethernet_protocol_data_in  : in ethernet_protocol_data_input_group;
        ethernet_protocol_data_out : out ethernet_protocol_data_output_group
    );
end entity ethernet_protocol;


architecture rtl of ethernet_protocol is 

    alias clock is ethernet_protocol_clocks.clock; 

------------------------------------------------------------------------ 
    signal frame_ram_read_control_port : ram_read_control_group;
    signal shift_register : std_logic_vector(47 downto 0);

    signal frame_received_shift_register : std_logic_vector(2 downto 0);
    signal ram_read_controller : ram_reader;
    signal ram_offset : natural range 0 to 2**11-1;

------------------------------------------------------------------------ 
    signal internet_protocol_clocks   : internet_protocol_clock_group;
    signal internet_protocol_data_in  : internet_protocol_data_input_group;
    signal internet_protocol_data_out : internet_protocol_data_output_group;
    signal internet_protocol_control  : protocol_control_record;

------------------------------------------------------------------------ 
begin

------------------------------------------------------------------------
------------------------------------------------------------------------
    route_data_out : process(frame_ram_read_control_port, internet_protocol_data_out.frame_ram_read_control, ram_offset) 
    begin
        ethernet_protocol_data_out <= (
                                          frame_ram_read_control => frame_ram_read_control_port + internet_protocol_data_out.frame_ram_read_control,
                                          ram_offset => ram_offset
                                      );

    end process route_data_out;	
------------------------------------------------------------------------
------------------------------------------------------------------------
    ethernet_protocol_processor : process(clock)
        
    begin
        if rising_edge(clock) then

            create_ram_read_controller(frame_ram_read_control_port, ethernet_protocol_data_in.frame_ram_output, ram_read_controller, shift_register); 
            -- frame_received_shift_register <= frame_received_shift_register(frame_received_shift_register'left-1 downto 0) & ethernet_protocol_data_in.toggle_frame_is_received;
            init_protocol_control(internet_protocol_control);

            if ethernet_protocol_data_in.protocol_processing_is_requested then 

               load_ram_with_offset_to_shift_register(ram_controller                     => ram_read_controller,
                                                       start_address                      => 0,
                                                       number_of_ram_addresses_to_be_read => 14+8);
            end if;

            if ram_data_is_ready(ethernet_protocol_data_in.frame_ram_output) then

                if get_ram_address(ethernet_protocol_data_in.frame_ram_output) = 14 then
                    if shift_register(15 downto 0) = x"0800" then
                        request_protocol_processing(internet_protocol_control, 14);
                    end if;
                end if;

                if get_ram_address(ethernet_protocol_data_in.frame_ram_output) = 14+8 then
                    if shift_register(7 downto 0) = x"11" then
                        ram_offset <= 14 + 8;
                    else
                        ram_offset <= 0;
                    end if;
                end if;

            end if; 

        end if; --rising_edge
    end process ethernet_protocol_processor;	

------------------------------------------------------------------------
    internet_protocol_clocks <= (clock => clock);

    internet_protocol_data_in <= (frame_ram_output => ethernet_protocol_data_in.frame_ram_output, 
                                 protocol_control => internet_protocol_control);

    u_internet_protocol : internet_protocol
    port map( internet_protocol_clocks,
    	  internet_protocol_data_in,
    	  internet_protocol_data_out); 

------------------------------------------------------------------------
end rtl;
