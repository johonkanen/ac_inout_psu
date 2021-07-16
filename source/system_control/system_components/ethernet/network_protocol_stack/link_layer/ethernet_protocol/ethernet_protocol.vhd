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

    signal shift_register : std_logic_vector(47 downto 0);
    signal frame_received_shift_register : std_logic_vector(2 downto 0);

    signal frame_ram_read_control_port : ram_read_control_group;

    type list_of_ethernet_protocol_processing_states is (wait_for_frame, source_mac_address, destination_mac_address, ethertype);
    signal ethernet_protocol_processing_state : list_of_ethernet_protocol_processing_states := wait_for_frame;

    signal ram_read_address : natural range 0 to 2**11-1;

------------------------------------------------------------------------
    procedure left_shift_register
    (
        signal shift_register : inout std_logic_vector;
        data_input : std_logic 
    ) is
    begin
        shift_register <= shift_register(shift_register'left-1 downto 0) & data_input;
    end left_shift_register;

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
    signal ram_read_is_requested : boolean := false;

    type ram_controller is record
        ram_read_port : ram_read_control_group;
        ram_address : natural;
        ram_start_address : natural;
    end record;

    procedure read_number_of_registers
    (
        start_address : natural;
        number_of_register_reads : natural;
        signal ram_control : inout ram_controller
    ) is
    begin
        
    end read_number_of_registers;

    signal number_of_ram_addresses_to_read : natural range 0 to 2**3-1; 
    signal ram_address : natural range 0 to 2**11-1;
    signal ram_offset  : natural range 0 to 2**11-1;

begin

------------------------------------------------------------------------
    ethernet_protocol_data_out <= (
                                      frame_ram_read_control => frame_ram_read_control_port
                                  );

------------------------------------------------------------------------
    ethernet_protocol_processor : process(clock)
        
    begin
        if rising_edge(clock) then

            init_ram_read(frame_ram_read_control_port);
            load_ram_to_shift_register(ethernet_protocol_data_in.frame_ram_output, shift_register);
            left_shift_register(frame_received_shift_register, ethernet_protocol_data_in.toggle_frame_is_received); 

            if ram_read_address > 0 then
                read_data_from_ram(frame_ram_read_control_port, ram_offset + ram_read_address - 1);
                ram_read_address <= ram_read_address - 1;
            end if;

            CASE ethernet_protocol_processing_state is
                WHEN wait_for_frame          =>
                    if toggle_detected_in(frame_received_shift_register) then
                    end if;
                WHEN destination_mac_address =>
                WHEN source_mac_address      =>
                WHEN ethertype               =>
            end CASE; 

        end if; --rising_edge
    end process ethernet_protocol_processor;	

end rtl;
