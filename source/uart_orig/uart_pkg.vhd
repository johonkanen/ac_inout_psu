library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_transreceiver_pkg.all;

package uart_pkg is

    type uart_clock_group is record
        clock : std_logic;
    end record;
    
    type uart_FPGA_input_group is record
        uart_transreceiver_FPGA_in  : uart_transreceiver_FPGA_input_group;
    end record;
    
    type uart_FPGA_output_group is record
        uart_transreceiver_FPGA_out : uart_transreceiver_FPGA_output_group;
    end record;
    
    type uart_data_input_group is record
        uart_transreceiver_data_in  : uart_transreceiver_data_input_group;
    end record;
    
    type uart_data_output_group is record
        uart_transreceiver_data_out : uart_transreceiver_data_output_group;
    end record;
    
    component uart is
        port (
            uart_clocks   : in uart_clock_group;
            uart_FPGA_in  : in uart_FPGA_input_group;
            uart_FPGA_out : out uart_FPGA_output_group;
            uart_data_in  : in uart_data_input_group;
            uart_data_out : out uart_data_output_group
        );
    end component uart;
    
    -- signal uart_clocks   : uart_clock_group;
    -- signal uart_data_in  : uart_data_input_group;
    -- signal uart_data_out : uart_data_output_group;
    
    -- u_uart : uart
    -- port map( uart_clocks,
    -- 	  uart_FPGA_in,
    --	  uart_FPGA_out,
    --	  uart_data_in,
    --	  uart_data_out);
----------------------------------------------------------------------
    procedure init_uart (
        signal uart_input : out uart_data_input_group);
----------------------------------------------------------------------
    procedure start_uart_transmitter (
        signal uart_input : out uart_data_input_group);
----------------------------------------------------------------------
    procedure load_16_bit_data_to_uart (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector);
------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector(15 downto 0));

    procedure transmit_16_bit_word_with_uart (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : integer);

------------------------------------------------------------------------
    function get_uart_rx_data ( uart_output : uart_data_output_group)
        return integer;

    procedure receive_data_from_uart (
        uart_output : in uart_data_output_group;
        signal received_data : out integer);
    
------------------------------------------------------------------------
end package uart_pkg;

package body uart_pkg is

------------------------------------------------------------------------
    procedure init_uart
    (
        signal uart_input : out uart_data_input_group
    ) is
    begin
        init_uart(uart_input.uart_transreceiver_data_in);
    end init_uart;

------------------------------------------------------------------------
    procedure start_uart_transmitter
    (
        signal uart_input : out uart_data_input_group
    ) is
    begin
        -- uart_input.uart_is_started_with_1 <= '1';
    end start_uart_transmitter; 

------------------------------------------------------------------------
    procedure load_16_bit_data_to_uart
    (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector
    ) is
    begin
        -- uart_input.uart_tx_data <= data_to_be_transmitted_with_uart;
        
    end load_16_bit_data_to_uart;

------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart
    (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector(15 downto 0)
    ) is
    begin

        transmit_16_bit_word_with_uart(uart_input.uart_transreceiver_data_in, data_to_be_transmitted_with_uart);
        
    end transmit_16_bit_word_with_uart;

------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart
    (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : integer
    ) is
        variable unsigned_data : unsigned(15 downto 0);
    begin
        unsigned_data := to_unsigned(data_to_be_transmitted_with_uart,16); 
        transmit_16_bit_word_with_uart(uart_input.uart_transreceiver_data_in, std_logic_vector(unsigned_data));
        
    end transmit_16_bit_word_with_uart;

------------------------------------------------------------------------
    function get_uart_rx_data
    (
        uart_output : uart_data_output_group
    )
    return integer
    is
    begin
        return 15;
    end get_uart_rx_data;

------------------------------------------------------------------------
    procedure receive_data_from_uart
    (
        uart_output : in uart_data_output_group;
        signal received_data : out integer
    ) is
        variable unsigned_data : unsigned(15 downto 0);
    begin
        if uart_data_packet_has_been_received(uart_output.uart_transreceiver_data_out) then
            unsigned_data := unsigned(get_received_data_packet(uart_output.uart_transreceiver_data_out));
            received_data <= to_integer(unsigned_data);
        end if;
        
    end receive_data_from_uart;
------------------------------------------------------------------------
end package body uart_pkg;

