library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package uart_tx_pkg is

    constant clock_in_uart_bit : natural := 24;
    constant bit_counter_high : natural := clock_in_uart_bit - 1;
    constant total_number_of_transmitted_bits_per_word : natural := 10;

    type uart_tx_clock_group is record
        clock : std_logic;
    end record;
    
    type uart_tx_FPGA_output_group is record
        uart_tx : std_logic;
    end record;
    
    type uart_tx_data_input_group is record
        uart_transmit_is_requested : boolean;
        data_to_be_transmitted : std_logic_vector(7 downto 0);
    end record;
    
    type uart_tx_data_output_group is record
        uart_tx_is_ready : boolean;
    end record;
    
    component uart_tx is
        port (
            uart_tx_clocks : in uart_tx_clock_group; 
            uart_tx_FPGA_out : out uart_tx_FPGA_output_group; 
            uart_tx_data_in : in uart_tx_data_input_group;
            uart_tx_data_out : out uart_tx_data_output_group
        );
    end component uart_tx;
    
    -- signal uart_tx_clocks   : uart_tx_clock_group;
    -- signal uart_tx_FPGA_out : uart_tx_FPGA_output_group;
    -- signal uart_tx_data_in  : uart_tx_data_input_group;
    -- signal uart_tx_data_out : uart_tx_data_output_group;
    
    -- u_uart_tx : uart_tx
    -- port map( uart_tx_clocks,
    --	  uart_tx_FPGA_out,
    --	  uart_tx_data_in,
    --	  uart_tx_data_out);
------------------------------------------------------------------------
    procedure init_uart (
        signal uart_tx_input : out uart_tx_data_input_group);
------------------------------------------------------------------------
    procedure transmit_8bit_data_package (
        signal uart_tx_input : out uart_tx_data_input_group;
        transmitted_data : std_logic_vector(7 downto 0));
------------------------------------------------------------------------
    function uart_tx_is_ready ( uart_tx_output : uart_tx_data_output_group)
        return boolean;
------------------------------------------------------------------------
    

end package uart_tx_pkg; 

package body uart_tx_pkg is

------------------------------------------------------------------------
    procedure init_uart
    (
        signal uart_tx_input : out uart_tx_data_input_group
    ) is
    begin
        uart_tx_input.uart_transmit_is_requested <= false;
    end init_uart;

------------------------------------------------------------------------
    procedure transmit_8bit_data_package
    (
        signal uart_tx_input : out uart_tx_data_input_group;
        transmitted_data : std_logic_vector(7 downto 0)
    ) is
    begin

        uart_tx_input.uart_transmit_is_requested <= true;
        uart_tx_input.data_to_be_transmitted <= transmitted_data; 
        
    end transmit_8bit_data_package;

------------------------------------------------------------------------
    function uart_tx_is_ready
    (
        uart_tx_output : uart_tx_data_output_group
    )
    return boolean
    is
    begin
        return uart_tx_output.uart_tx_is_ready;
    end uart_tx_is_ready;
------------------------------------------------------------------------
end package body uart_tx_pkg; 
