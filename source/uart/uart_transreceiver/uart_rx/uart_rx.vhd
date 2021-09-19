library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_rx_pkg.all;

entity uart_rx is
    port (
        uart_rx_clocks   : in uart_rx_clock_group;
        uart_rx_FPGA_in  : in uart_rx_FPGA_input_group;
        uart_rx_data_in  : in uart_rx_data_input_group;
        uart_rx_data_out : out uart_rx_data_output_group
    );
end entity;

architecture rtl of uart_rx is

    alias clock is uart_rx_clocks.clock;

    signal receive_register : std_logic_vector(9 downto 0) := (others => '0');
    signal receive_bit_counter : natural range 0 to 127 := 23/2;
    signal counter_for_number_of_received_bits : natural range 0 to 15 := 0;
    signal received_data : std_logic_vector(7 downto 0);
    signal input_buffer : std_logic_vector(1 downto 0);
    signal uart_rx_data_transmission_is_ready : boolean := false;


    signal counter_for_data_bit : natural range 0 to 127:= 0; 

    constant bit_counter_high : integer := 23;
    constant total_number_of_transmitted_bits_per_word : integer := 10;

begin

    uart_rx_data_out <= (uart_rx_data => received_data, uart_rx_data_transmission_is_ready => uart_rx_data_transmission_is_ready);

    uart_rx_receiver : process(clock)

    --------------------------------------------------
        function read_bit_as_1_if_counter_higher_than
        (
            limit_for_bit_being_high : natural;
            counter_for_bit : natural 
        )
        return std_logic
        is
        begin
            if counter_for_bit > limit_for_bit_being_high then
                return '1';
            else
                return '0';
            end if;
            
        end read_bit_as_1_if_counter_higher_than;

    --------------------------------------------------
        function "+"
        (
            left : integer;
            right : std_logic 
        )
        return integer
        is
        begin
            if right = '1' then
                return left + 1;
            else
                return left;
            end if;
        end "+";

    --------------------------------------------------
        type list_of_uart_rx_states is (wait_for_start_bit, receive_data);
        variable uart_rx_state : list_of_uart_rx_states := wait_for_start_bit;
        
    begin
        if rising_edge(clock) then

            input_buffer <= input_buffer(input_buffer'left-1 downto 0) & uart_rx_FPGA_in.uart_rx;
            uart_rx_data_transmission_is_ready <= false;

            CASE uart_rx_state is
                WHEN wait_for_start_bit =>
                    counter_for_data_bit <= 0;
                    counter_for_number_of_received_bits <= 0;
                    uart_rx_state := wait_for_start_bit;
                    if input_buffer(input_buffer'left) = '0' then
                        receive_bit_counter <= bit_counter_high;
                        uart_rx_state := receive_data;
                    end if;

                WHEN receive_data =>
                    counter_for_data_bit <= counter_for_data_bit + input_buffer(input_buffer'left);
                    if receive_bit_counter /= 0 then
                        receive_bit_counter <= receive_bit_counter - 1;
                    else 
                        receive_bit_counter <= bit_counter_high;
                        counter_for_number_of_received_bits <= counter_for_number_of_received_bits + 1;

                        if counter_for_number_of_received_bits = total_number_of_transmitted_bits_per_word - 1 then
                            uart_rx_state := wait_for_start_bit;
                            counter_for_number_of_received_bits <= 0;
                            uart_rx_data_transmission_is_ready <= true;
                            received_data <= receive_register(9 downto 2);
                        else 
                            receive_register <= read_bit_as_1_if_counter_higher_than(bit_counter_high/2-1, counter_for_data_bit) & receive_register(receive_register'left downto 1);
                            counter_for_data_bit <= 0;
                        end if;

                    end if; 
            end CASE;

        end if; --rising_edge
    end process uart_rx_receiver;	

end rtl;
