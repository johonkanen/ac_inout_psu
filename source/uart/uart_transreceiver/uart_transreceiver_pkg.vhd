library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_rx_pkg.all;
    use work.uart_tx_pkg.all;

package uart_transreceiver_pkg is

    type uart_transreceiver_clock_group is record
        clock : std_logic;
    end record;
    
    type uart_transreceiver_FPGA_input_group is record
        uart_rx_FPGA_in : uart_rx_FPGA_input_group; 
    end record;
    
    type uart_transreceiver_FPGA_output_group is record
        uart_tx_FPGA_out : uart_tx_FPGA_output_group; 
    end record;
    
    type uart_transreceiver_data_input_group is record
        uart_tx_data_in : uart_tx_data_input_group;
        uart_data_packet : std_logic_vector(15 downto 0);
        uart_data_packet_transmission_is_requested : boolean;
    end record;
    
    type uart_transreceiver_data_output_group is record
        received_data_packet : std_logic_vector(15 downto 0);
        uart_data_packet_is_received : boolean;
        uart_data_packet_transmission_is_ready : boolean;
        uart_tx_data_out : uart_tx_data_output_group;
        uart_rx_data_out : uart_rx_data_output_group;
    end record;
    
    component uart_transreceiver is
        port (
            uart_transreceiver_clocks   : in uart_transreceiver_clock_group;
            uart_transreceiver_FPGA_in  : in uart_transreceiver_FPGA_input_group;
            uart_transreceiver_FPGA_out : out uart_transreceiver_FPGA_output_group;
            uart_transreceiver_data_in  : in uart_transreceiver_data_input_group;
            uart_transreceiver_data_out : out uart_transreceiver_data_output_group
        );
    end component uart_transreceiver;

------------------------------------------------------------------------
    procedure init_uart (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group);
------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group;
        data_packet : in std_logic_vector(15 downto 0));
------------------------------------------------------------------------
    procedure transmit_data_with_uart (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group;
        data_to_transmit : std_logic_vector(7 downto 0));
------------------------------------------------------------------------
    function uart_data_has_been_received ( uart_transreceiver_out : uart_transreceiver_data_output_group )
        return boolean;
------------------------------------------------------------------------
    function get_received_data_packet ( uart_transreceiver_out : uart_transreceiver_data_output_group)
        return std_logic_vector;
------------------------------------------------------------------------
    function uart_data_packet_has_been_received ( uart_transreceiver_out : uart_transreceiver_data_output_group)
        return boolean;
    
    -- signal uart_transreceiver_clocks   : uart_transreceiver_clock_group;
    -- signal uart_transreceiver_FPGA_in  : uart_transreceiver_FPGA_input_group;
    -- signal uart_transreceiver_FPGA_out : uart_transreceiver_FPGA_output_group;
    -- signal uart_transreceiver_data_in  : uart_transreceiver_data_input_group;
    -- signal uart_transreceiver_data_out : uart_transreceiver_data_output_group
    
    -- u_uart_transreceiver : uart_transreceiver
    -- port map( uart_transreceiver_clocks,
    -- 	  uart_transreceiver_FPGA_in,
    --	  uart_transreceiver_FPGA_out,
    --	  uart_transreceiver_data_in,
    --	  uart_transreceiver_data_out);
    

end package uart_transreceiver_pkg;

package body uart_transreceiver_pkg is

------------------------------------------------------------------------
    procedure init_uart
    (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group
    ) is
    begin

        init_uart(uart_transreceiver_in.uart_tx_data_in);
        uart_transreceiver_in.uart_data_packet_transmission_is_requested <= false;
        
    end init_uart;

------------------------------------------------------------------------
    procedure transmit_16_bit_word_with_uart
    (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group;
        data_packet : in std_logic_vector(15 downto 0)
    ) is
    begin
        uart_transreceiver_in.uart_data_packet_transmission_is_requested <= true;
        uart_transreceiver_in.uart_data_packet <= data_packet;

    end transmit_16_bit_word_with_uart;

------------------------------------------------------------------------
    procedure transmit_data_with_uart
    (
        signal uart_transreceiver_in : out uart_transreceiver_data_input_group;
        data_to_transmit : std_logic_vector(7 downto 0)
    ) is
    begin
        transmit_8bit_data_package(uart_transreceiver_in.uart_tx_data_in, data_to_transmit);
    end transmit_data_with_uart;

------------------------------------------------------------------------
    function uart_data_has_been_received
    (
        uart_transreceiver_out : uart_transreceiver_data_output_group 
    )
    return boolean
    is
    begin
        return uart_rx_data_is_ready(uart_transreceiver_out.uart_rx_data_out);
        
    end uart_data_has_been_received;

------------------------------------------------------------------------
    function get_received_data_packet
    (
        uart_transreceiver_out : uart_transreceiver_data_output_group
    )
    return std_logic_vector
    is
    begin
        return uart_transreceiver_out.received_data_packet;
        
    end get_received_data_packet;

------------------------------------------------------------------------
    function uart_data_packet_has_been_received
    (
        uart_transreceiver_out : uart_transreceiver_data_output_group
    )
    return boolean
    is
    begin
        return uart_transreceiver_out.uart_data_packet_is_received;
    end uart_data_packet_has_been_received;
end package body uart_transreceiver_pkg;

