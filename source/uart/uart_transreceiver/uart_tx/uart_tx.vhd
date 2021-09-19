library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_tx_pkg.all; 

entity uart_tx is
    port (
        uart_tx_clocks   : in uart_tx_clock_group;
        uart_tx_FPGA_out : out uart_tx_FPGA_output_group;
        uart_tx_data_in  : in uart_tx_data_input_group;
        uart_tx_data_out : out uart_tx_data_output_group
    );
end entity;

architecture rtl of uart_tx is

    alias clock is uart_tx_clocks.clock;

    signal transmit_register : std_logic_vector(9 downto 0) := (others => '1');
    signal transmit_bit_counter : integer range -1 to 127;
    signal transmit_data_bit_counter : natural range 0 to 15; 

begin

    uart_tx_FPGA_out <= (uart_tx => transmit_register(transmit_register'right));

------------------------------------------------------------------------
    uart_transmitter : process(clock)

        --------------------------------------------------
        procedure shift_and_register
        (
            signal shift_register : inout std_logic_vector
        ) is
        begin
            shift_register <= '1' & shift_register(shift_register'left downto 1);
        end shift_and_register; 

        --------------------------------------------------
        procedure load_data_with_start_and_stop_bits_to
        (
            signal transmitter_register : out std_logic_vector;
            data_to_be_transmitted : in std_logic_vector
        ) is
        begin

            transmitter_register <= '1' & data_to_be_transmitted & '0';

        end load_data_with_start_and_stop_bits_to;

        --------------------------------------------------

        type list_of_uart_transmitter_states is (wait_for_transmit_request, transmit);
        variable uart_transmitter_state : list_of_uart_transmitter_states := wait_for_transmit_request;

    begin
        if rising_edge(clock) then

            uart_tx_data_out.uart_tx_is_ready <= false;
            CASE uart_transmitter_state is

                WHEN wait_for_transmit_request =>
                    uart_transmitter_state := wait_for_transmit_request;

                    transmit_data_bit_counter <= 0;

                    transmit_bit_counter <= bit_counter_high;
                    if uart_tx_data_in.uart_transmit_is_requested then
                        load_data_with_start_and_stop_bits_to(transmit_register, uart_tx_data_in.data_to_be_transmitted);
                        uart_transmitter_state := transmit; 
                    end if;

                WHEN transmit =>
                    uart_transmitter_state := transmit;

                    transmit_bit_counter <= transmit_bit_counter - 1;
                    if transmit_bit_counter = 0 then
                        transmit_data_bit_counter <= transmit_data_bit_counter + 1;
                        transmit_bit_counter <= bit_counter_high;
                        shift_and_register(transmit_register); 
                        if transmit_data_bit_counter = transmit_register'high then
                            uart_transmitter_state := wait_for_transmit_request;
                            uart_tx_data_out.uart_tx_is_ready <= true;
                        end if;
                    end if; 

            end CASE; 

        end if; --rising_edge
    end process uart_transmitter;	

------------------------------------------------------------------------
end rtl; 
