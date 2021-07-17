library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;
    use work.internet_protocol_pkg.all;

entity internet_protocol is
    port (
        internet_protocol_clocks : in internet_protocol_clock_group; 
        internet_protocol_data_in : in internet_protocol_data_input_group;
        internet_protocol_data_out : out internet_protocol_data_output_group
    );
end entity internet_protocol;

architecture rtl of internet_protocol is

    alias clock is internet_protocol_clocks.clock;
    signal frame_ram_read_control_port : ram_read_control_group;
    signal shift_register : std_logic_vector(31 downto 0);
    signal ram_read_controller : ram_reader;
    signal ram_offset : natural range 0 to 2**11-1;
    
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

        end if; --rising_edge
    end process ip_header_processor;	

end rtl;

