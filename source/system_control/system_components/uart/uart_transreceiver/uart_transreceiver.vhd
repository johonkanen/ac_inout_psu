library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
    use work.uart_transreceiver_pkg.all;
    use work.uart_rx_pkg.all;
    use work.uart_tx_pkg.all;

entity uart_transreceiver is
    port (
        uart_transreceiver_clocks   : in uart_transreceiver_clock_group;
        uart_transreceiver_FPGA_in  : in uart_transreceiver_FPGA_input_group;
        uart_transreceiver_FPGA_out : out uart_transreceiver_FPGA_output_group;
        uart_transreceiver_data_in  : in uart_transreceiver_data_input_group;
        uart_transreceiver_data_out : out uart_transreceiver_data_output_group
    );
end entity;

architecture rtl of uart_transreceiver is

    signal uart_rx_clocks   : uart_rx_clock_group;
    signal uart_rx_data_in  : uart_rx_data_input_group;
    
    signal uart_tx_clocks   : uart_tx_clock_group;

begin

------------------------------------------------------------------------
    uart_rx_clocks <= (clock => uart_transreceiver_clocks.clock);
    u_uart_rx : uart_rx
    port map( uart_rx_clocks,
    	  uart_transreceiver_FPGA_in.uart_rx_FPGA_in,
    	  uart_rx_data_in,
    	  uart_transreceiver_data_out.uart_rx_data_out); 

------------------------------------------------------------------------
    uart_tx_clocks <= (clock => uart_transreceiver_clocks.clock);
    u_uart_tx : uart_tx
    port map( uart_tx_clocks,
    	  uart_transreceiver_FPGA_out.uart_tx_FPGA_out,
    	  uart_transreceiver_data_in.uart_tx_data_in,
    	  uart_transreceiver_data_out.uart_tx_data_out);

------------------------------------------------------------------------
end rtl; 
