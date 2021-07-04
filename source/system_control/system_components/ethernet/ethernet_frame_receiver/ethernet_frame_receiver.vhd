library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_rx_ddio_pkg.all; 

entity ethernet_frame_receiver is
    port (
        ethernet_frame_receiver_clocks  : in ethernet_rx_ddr_clock_group;
        ethernet_frame_receiver_FPGA_in : in ethernet_frame_receiver_FPGA_input_group;
        ethernet_frame_receiver_data_in : in ethernet_frame_receiver_data_input_group;
        ethernet_frame_receiver_data_out : out ethernet_frame_receiver_data_output_group
    );
end entity ethernet_frame_receiver;

architecture rtl of ethernet_frame_receiver is

    signal ethernet_rx_ddio_data_out  : ethernet_rx_ddio_data_output_group;

    alias rx_ddr_clock is ethernet_frame_receiver_clocks.rx_ddr_clock;


    signal rx_shift_register : std_logic_vector(15 downto 0) := (others => '0'); 
    signal test_data : bytearray(0 to 63);
    signal data_has_been_written_when_1 : std_logic := '0';
    signal bytearray_index_counter : natural range 0 to 127;
    signal data_is_read_from_buffer : boolean;

    function get_reversed_byte
    (
        ethernet_shift_register : std_logic_vector
    )
    return std_logic_vector 
    is
        variable byte_reversed : std_logic_vector(7 downto 0);
        variable buffered_byte : std_logic_vector(7 downto 0);
    begin
        buffered_byte := ethernet_shift_register(15 downto 8);

        byte_reversed := buffered_byte(0) &
                         buffered_byte(1) &
                         buffered_byte(2) &
                         buffered_byte(3) &
                         buffered_byte(4) &
                         buffered_byte(5) &
                         buffered_byte(6) &
                         buffered_byte(7);

        return byte_reversed; 

        
    end get_reversed_byte;
    
begin

    ethernet_frame_receiver_data_out <= (test_data => test_data, data_has_been_written_when_1 => data_has_been_written_when_1);

    frame_receiver : process(rx_ddr_clock) 
        type list_of_frame_receiver_states is (wait_for_start_of_frame, receive_frame);
        variable frame_receiver_state : list_of_frame_receiver_states := wait_for_start_of_frame;
    begin
        if rising_edge(rx_ddr_clock) then 

            rx_shift_register <= rx_shift_register(7 downto 0) & get_byte(ethernet_rx_ddio_data_out); 

            if ethernet_rx_active(ethernet_rx_ddio_data_out) then
                CASE frame_receiver_state is
                    WHEN wait_for_start_of_frame =>
                        if rx_shift_register = x"AAAB" then
                            frame_receiver_state := receive_frame;
                        end if;

                    WHEN receive_frame =>
                        data_is_read_from_buffer <= not data_is_read_from_buffer;

                        if bytearray_index_counter < 64 then
                            bytearray_index_counter <= bytearray_index_counter + 1;

                            if data_is_read_from_buffer then
                                test_data(bytearray_index_counter) <= get_reversed_byte(rx_shift_register);
                            else
                                test_data(bytearray_index_counter) <= get_reversed_byte(ethernet_rx_ddio_data_out);
                            end if;
                        end if;

                end CASE;
            else
                bytearray_index_counter <= 0;
                frame_receiver_state := wait_for_start_of_frame;
                data_is_read_from_buffer <= false;

            end if; 

        end if; --rising_edge
    end process frame_receiver;	

------------------------------------------------------------------------
    u_ethernet_rx_ddio : ethernet_rx_ddio
    port map( ethernet_frame_receiver_clocks                           ,
              ethernet_frame_receiver_FPGA_in.ethernet_rx_ddio_FPGA_in ,
              ethernet_rx_ddio_data_out);

------------------------------------------------------------------------
end rtl;
