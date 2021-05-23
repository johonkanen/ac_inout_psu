library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;
    use work.uart_transreceiver_pkg.all;

entity uart is
    port (
        uart_clocks   : in uart_clock_group;
        uart_FPGA_in  : in uart_FPGA_input_group;
        uart_FPGA_out : out uart_FPGA_output_group;
        uart_data_in  : in uart_data_input_group;
        uart_data_out : out uart_data_output_group
    );
end entity uart;

architecture rtl of uart is

    alias uart_clk is uart_clocks.clock;

    signal uart_transreceiver_clocks   : uart_transreceiver_clock_group;
    -- signal uart_transreceiver_FPGA_in  : uart_transreceiver_FPGA_input_group;
    -- signal uart_transreceiver_FPGA_out : uart_transreceiver_FPGA_output_group;
    -- signal uart_transreceiver_data_in  : uart_transreceiver_data_input_group;
    -- signal uart_transreceiver_data_out : uart_transreceiver_data_output_group;

begin

    uart_transreceiver_clocks <= (clock => uart_clk);

    u_uart_transreceiver : uart_transreceiver
    port map( uart_transreceiver_clocks,
    	  uart_FPGA_in.uart_transreceiver_FPGA_in,
    	  uart_FPGA_out.uart_transreceiver_FPGA_out,
    	  uart_data_in.uart_transreceiver_data_in,
    	  uart_data_out.uart_transreceiver_data_out);


end rtl;
