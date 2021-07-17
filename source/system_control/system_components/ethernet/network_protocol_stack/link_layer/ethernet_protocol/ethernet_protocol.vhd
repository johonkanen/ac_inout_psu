library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;
    use work.ethernet_protocol_pkg.all; 

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
    function toggle_detected_in
    (
        shift_vector : std_logic_vector 
    )
    return boolean
    is
    begin
        return shift_vector(shift_vector'left) = shift_vector(shift_vector'left-1);
    end toggle_detected_in;
------------------------------------------------------------------------


    signal frame_ram_read_control_port : ram_read_control_group;
    signal shift_register : std_logic_vector(47 downto 0);

    type list_of_ethernet_protocol_processing_states is (wait_for_frame, source_mac_address, destination_mac_address, ethertype);
    signal ethernet_protocol_processing_state : list_of_ethernet_protocol_processing_states := wait_for_frame;
    signal frame_received_shift_register : std_logic_vector(2 downto 0);

    signal ram_read_controller : ram_reader;

begin

------------------------------------------------------------------------
    ethernet_protocol_data_out <= (
                                      frame_ram_read_control => frame_ram_read_control_port
                                  );

------------------------------------------------------------------------
    ethernet_protocol_processor : process(clock)
        
    begin
        if rising_edge(clock) then

            create_ram_read_controller(frame_ram_read_control_port, ethernet_protocol_data_in.frame_ram_output, ram_read_controller, shift_register); 

            -- CASE ethernet_protocol_processing_state is
            --     WHEN wait_for_frame          =>
            --         if toggle_detected_in(frame_received_shift_register) then
            --
            --
            --             -- read destination mac address
            --             load_ram_with_offset_to_shift_register(ram_controller                     => ram_read_controller,
            --                                                    start_address                      => 0,
            --                                                    number_of_ram_addresses_to_be_read => 14);
            --         end if;
            --     WHEN destination_mac_address =>
            --         if ram_is_buffered_to_shift_register(ram_read_controller) then
            --
            --             -- read source mac address
            --             load_ram_with_offset_to_shift_register(ram_controller                     => ram_read_controller,
            --                                                    start_address                      => 6,
            --                                                    number_of_ram_addresses_to_be_read => 6);
            --         end if;
            --     WHEN source_mac_address =>
            --
            --         if ram_is_buffered_to_shift_register(ram_read_controller) then
            --
            --             -- read source mac address
            --             load_ram_with_offset_to_shift_register(ram_controller                     => ram_read_controller,
            --                                                    start_address                      => 12,
            --                                                    number_of_ram_addresses_to_be_read => 2);
            --         end if;
            --     WHEN ethertype =>
            --         if ram_is_buffered_to_shift_register(ram_read_controller) then
            --
            --             if shift_register(15 downto 0) = x"0800" then
            --             end if;
            --         end if;
            -- end CASE; 
            --
        end if; --rising_edge
    end process ethernet_protocol_processor;	

end rtl;
