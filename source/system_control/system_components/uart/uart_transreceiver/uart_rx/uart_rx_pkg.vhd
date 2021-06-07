library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package uart_rx_pkg is

    type uart_rx_clock_group is record
        clock : std_logic;
    end record;
    
    type uart_rx_FPGA_input_group is record
        uart_rx : std_logic;
    end record;
    
    type uart_rx_data_input_group is record
        clock : std_logic;
    end record;
    
    type uart_rx_data_output_group is record
        uart_rx_data : std_logic_vector(7 downto 0);
        uart_rx_data_transmission_is_ready : boolean;
    end record;
    
    component uart_rx is
        port (
            uart_rx_clocks   : in uart_rx_clock_group;
            uart_rx_FPGA_in  : in uart_rx_FPGA_input_group;
            uart_rx_data_in  : in uart_rx_data_input_group;
            uart_rx_data_out : out uart_rx_data_output_group
        );
    end component uart_rx;
    
------------------------------------------------------------------------
    function uart_rx_data_is_ready ( uart_rx_out : uart_rx_data_output_group)
        return boolean;
------------------------------------------------------------------------
    function get_uart_rx_data ( uart_rx_out : uart_rx_data_output_group)
        return std_logic_vector;
------------------------------------------------------------------------

    -- signal uart_rx_clocks   : uart_rx_clock_group;
    -- signal uart_rx_FPGA_in  : uart_rx_FPGA_input_group;
    -- signal uart_rx_data_in  : uart_rx_data_input_group;
    -- signal uart_rx_data_out : uart_rx_data_output_group
    
    -- u_uart_rx : uart_rx
    -- port map( uart_rx_clocks,
    -- 	  uart_rx_FPGA_in,
    --	  uart_rx_FPGA_out,
    --	  uart_rx_data_in,
    --	  uart_rx_data_out); 

end package uart_rx_pkg;

package body uart_rx_pkg is

------------------------------------------------------------------------
    function uart_rx_data_is_ready
    (
        uart_rx_out : uart_rx_data_output_group
    )
    return boolean
    is
    begin
        return uart_rx_out.uart_rx_data_transmission_is_ready;
    end uart_rx_data_is_ready;

------------------------------------------------------------------------
    function get_uart_rx_data
    (
        uart_rx_out : uart_rx_data_output_group
    )
    return std_logic_vector 
    is
    begin
        return uart_rx_out.uart_rx_data; 
    end get_uart_rx_data;

------------------------------------------------------------------------
end package body uart_rx_pkg;
