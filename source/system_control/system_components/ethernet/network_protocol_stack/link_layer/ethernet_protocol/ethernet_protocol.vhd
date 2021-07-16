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

    procedure left_shift_register
    (
        signal shift_register : inout std_logic_vector;
        data_input : std_logic 
    ) is
    begin
        shift_register <= shift_register(shift_register'left-1 downto 0) & data_input;
    end left_shift_register;

    function is_toggled
    (
        shift_vector : std_logic_vector 
    )
    return boolean
    is
    begin
        return shift_vector(shift_vector'left) = shift_vector(shift_vector'left-1);
    end is_toggled;

begin

    ethernet_protocol_data_out <= (
                                      frame_ram_read_control => frame_ram_read_control_port
                                  );

    ethernet_protocol_processor : process(clock)
        
    begin
        if rising_edge(clock) then

            init_ram_read(frame_ram_read_control_port);
            load_ram_to_shift_register(ethernet_protocol_data_in.frame_ram_output, shift_register);
            left_shift_register(frame_received_shift_register, ethernet_protocol_data_in.toggle_frame_is_received); 

        end if; --rising_edge
    end process ethernet_protocol_processor;	

end rtl;
