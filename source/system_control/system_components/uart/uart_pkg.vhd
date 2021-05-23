library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package uart_pkg is

    constant CLKS_PER_BIT : integer := 120e6/5e6;
    constant RX_bytes_in_word : integer := 2;
    constant TX_bytes_in_word : integer := 2;


    type uart_clock_group is record
        clock : std_logic;
    end record;
    
    type uart_FPGA_input_group is record
        uart_rx : std_logic;
    end record;
    
    type uart_FPGA_output_group is record
        uart_tx : std_logic;
    end record;
    
    type uart_data_input_group is record
        uart_is_started_with_1 : std_logic;
        uart_tx_data           : std_logic_vector(15 downto 0);
    end record;
    
    type uart_data_output_group is record
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
    function uart_receiver_is_ready ( uart_output : uart_data_output_group)
        return boolean;

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
        uart_input.uart_is_started_with_1 <= '0';
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
        uart_input.uart_tx_data <= data_to_be_transmitted_with_uart(7 downto 0) & data_to_be_transmitted_with_uart(15 downto 8);
        
    end load_16_bit_data_to_uart;

------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart
    (
        signal uart_input : out uart_data_input_group;
        data_to_be_transmitted_with_uart : std_logic_vector(15 downto 0)
    ) is
    begin
        load_16_bit_data_to_uart(uart_input, data_to_be_transmitted_with_uart);
        start_uart_transmitter(uart_input);
        
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

        load_16_bit_data_to_uart(uart_input, std_logic_vector(unsigned_data));
        start_uart_transmitter(uart_input);
        
    end transmit_16_bit_word_with_uart;

------------------------------------------------------------------------
    function uart_receiver_is_ready
    (
        uart_output : uart_data_output_group
    )
    return boolean
    is
    begin
        if uart_output.uart_rx_ready_when_1 = '1' then
            return true;
        else
            return false;
        end if;
        
    end uart_receiver_is_ready;

------------------------------------------------------------------------
    function get_uart_rx_data
    (
        uart_output : uart_data_output_group
    )
    return integer
    is
    begin
        return to_integer(unsigned(uart_output.uart_rx_data));
    end get_uart_rx_data;

------------------------------------------------------------------------
    procedure receive_data_from_uart
    (
        uart_output : in uart_data_output_group;
        signal received_data : out integer
    ) is
    begin
        if uart_receiver_is_ready(uart_output) then
            received_data <= get_uart_rx_data(uart_output);
        end if;
        
    end receive_data_from_uart;
------------------------------------------------------------------------
end package body uart_pkg;

