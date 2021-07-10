library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_rx_ddio_pkg.all; 
    use work.PCK_CRC32_D8.all;

entity ethernet_frame_receiver is
    port (
        ethernet_frame_receiver_clocks   : in ethernet_rx_ddr_clock_group;
        ethernet_frame_receiver_FPGA_in  : in ethernet_frame_receiver_FPGA_input_group;
        ethernet_frame_receiver_data_in  : in ethernet_frame_receiver_data_input_group;
        ethernet_frame_receiver_data_out : out ethernet_frame_receiver_data_output_group
    );
end entity ethernet_frame_receiver;

architecture rtl of ethernet_frame_receiver is

    signal ethernet_rx_ddio_data_out  : ethernet_rx_ddio_data_output_group;

    alias rx_ddr_clock is ethernet_frame_receiver_clocks.rx_ddr_clock; 

    signal rx_shift_register : std_logic_vector(15 downto 0) := (others => '0'); 
    signal test_data : bytearray;
    signal data_has_been_written_when_1 : std_logic := '0';
    signal bytearray_index_counter : natural range 0 to bytearray'high;

    signal fcs_shift_register : std_logic_vector(31 downto 0) := (others => '1');

    signal counter : natural range 0 to 15;
    
    signal crc_is_ok : boolean := false;

    type list_of_frame_receiver_states is (wait_for_start_of_frame, receive_frame);
    signal frame_receiver_state : list_of_frame_receiver_states := wait_for_start_of_frame; 

begin

    ethernet_frame_receiver_data_out <= (test_data => test_data, data_has_been_written_when_1 => data_has_been_written_when_1); 

    frame_receiver : process(rx_ddr_clock) 

    --------------------------------------------------
    begin
        if rising_edge(rx_ddr_clock) then 

            rx_shift_register <= rx_shift_register(7 downto 0) & get_byte(ethernet_rx_ddio_data_out); 

            if fcs_shift_register = x"c704dd7b" then
                crc_is_ok <= true; 
            end if;


            if ethernet_rx_is_active(ethernet_rx_ddio_data_out) then
                CASE frame_receiver_state is
                    WHEN wait_for_start_of_frame =>
                        if rx_shift_register = x"AAAA" and get_byte(ethernet_rx_ddio_data_out) = x"ab"  then
                            frame_receiver_state <= receive_frame;
                        end if;

                    WHEN receive_frame =>

                        counter <= 0; 
                        if bytearray_index_counter < bytearray'high then
                            bytearray_index_counter <= bytearray_index_counter + 1;

                            test_data(bytearray_index_counter) <= get_reversed_byte(ethernet_rx_ddio_data_out);
                        end if;

                        if fcs_shift_register /= x"c704dd7b" then
                            fcs_shift_register <= nextCRC32_D8(get_byte(ethernet_rx_ddio_data_out), fcs_shift_register);
                        end if;

                end CASE;
            else
                if bytearray_index_counter > 0 and bytearray_index_counter /= bytearray'high then
                    bytearray_index_counter <= bytearray_index_counter + 1;

                    if crc_is_ok then
                        test_data(bytearray_index_counter) <= x"EE";
                    else
                        test_data(bytearray_index_counter) <= x"dd";
                    end if;
                    if counter < 4 then
                        counter <= counter + 1;
                        CASE counter is
                            WHEN 0 => test_data(bytearray_index_counter) <= fcs_shift_register(7  downto 0);
                            WHEN 1 => test_data(bytearray_index_counter) <= fcs_shift_register(15 downto 8);
                            WHEN 2 => test_data(bytearray_index_counter) <= fcs_shift_register(23 downto 16);
                            WHEN 3 => test_data(bytearray_index_counter) <= fcs_shift_register(31 downto 24);
                            WHEN others => -- do notihing
                        end CASE;
                    end if;
                else
                    bytearray_index_counter <= 0;
                    fcs_shift_register <= (others => '1');
                    crc_is_ok <= false; 

                    frame_receiver_state <= wait_for_start_of_frame;
                end if;

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
