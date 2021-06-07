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
        uart_is_started_with_1 : std_logic;
        uart_tx_data           : std_logic_vector(15 downto 0);
    end record;
    
    type uart_data_output_group is record
        uart_transreceiver_data_out : uart_transreceiver_data_output_group;
        uart_rx_ready_when_1 : std_logic;
        uart_rx_data         : std_logic_vector(15 downto 0);
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
        uart_input.uart_is_started_with_1 <= '1';
    end start_uart_transmitter; 

------------------------------------------------------------------------
    procedure load_16_bit_data_to_uart
    (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector
    ) is
    begin
        uart_input.uart_tx_data <= data_to_be_transmitted_with_uart(15 downto 0);
        
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
end package body uart_pkg;

