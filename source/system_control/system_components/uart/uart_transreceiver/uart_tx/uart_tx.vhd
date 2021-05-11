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

    --------------------------------------------------
    procedure shift_and_register
    (
        signal shift_register : inout std_logic_vector
    ) is
    begin
        shift_register <= shift_register(shift_register'left-1 downto 0) & '1';
    end shift_and_register; 

    --------------------------------------------------
    procedure shift_and_register_when
    (
        shift_is_requested : boolean;
        signal shift_register : inout std_logic_vector 
    ) is
    begin
        if shift_is_requested then
            shift_and_register(shift_register);
        end if;
        
    end shift_and_register_when;

    --------------------------------------------------
    procedure load_data_with_start_and_stop_bits_to
    (
        signal transmit_register : out std_logic_vector;
        data_to_be_transmitted : in std_logic_vector
    ) is
    begin

        transmit_register <= '0' & data_to_be_transmitted & '0';

    end load_data_with_start_and_stop_bits_to;

    signal transmit_register : std_logic_vector(9 downto 0) := (others => '0');
    signal transmit_bit_counter : natural range 0 to 15;
    constant clock_in_uart_bit : natural := 6;
    constant bit_counter_high : natural := clock_in_uart_bit - 1;
    signal transmit_data_bit_counter : natural range 0 to 15;


begin

    uart_tx_FPGA_out <= (uart_tx => transmit_register(transmit_register'left));

------------------------------------------------------------------------
    uart_transmitter : process(clock)

        type t_uart_tansmitter is (idle, transmit);
        variable st_uart_tansmitter : t_uart_tansmitter := idle;

    begin
        if rising_edge(clock) then

            CASE st_uart_tansmitter is
                WHEN idle =>
                    st_uart_tansmitter := idle;
                    transmit_data_bit_counter <= 0;
                    transmit_bit_counter <= bit_counter_high;
                    if uart_tx_data_in.uart_transmit_is_requested then
                        load_data_with_start_and_stop_bits_to(transmit_register, uart_tx_data_in.data_to_be_transmitted);
                        st_uart_tansmitter := transmit; 
                    end if;
                WHEN transmit =>
                    if transmit_bit_counter = 0 then
                        transmit_bit_counter <= bit_counter_high;
                        shift_and_register(transmit_register); 
                        transmit_data_bit_counter <= transmit_data_bit_counter + 1;
                        if transmit_data_bit_counter = 9 then
                            st_uart_tansmitter := idle;
                        end if;
                    else
                        transmit_bit_counter <= transmit_bit_counter - 1;
                    end if;

            end CASE;

        end if; --rising_edge
    end process uart_transmitter;	

------------------------------------------------------------------------
end rtl; 
