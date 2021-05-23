library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_components_pkg.all;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;

entity system_components is
    port (
        system_components_clocks   : in  system_components_clock_group;
        system_components_FPGA_in  : in  system_components_FPGA_input_group;
        system_components_FPGA_out : out system_components_FPGA_output_group;
        system_components_data_in  : in  system_components_data_input_group;
        system_components_data_out : out system_components_data_output_group
    );
end entity system_components;

architecture rtl of system_components is

    alias clock is system_components_clocks.clock;
    alias reset_n is system_components_clocks.reset_n;

    signal power_supply_control_clocks   : power_supply_control_clock_group;
    signal power_supply_control_data_in  : power_supply_control_data_input_group;
    signal power_supply_control_data_out : power_supply_control_data_output_group;
    
    signal uart_clocks   : uart_clock_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal uart_transmit_counter : natural range 0 to 2**16-1 := 0;
    constant counter_at_100khz   : natural                    := 120e6/100e3;
    signal transmit_counter      : natural range 0 to 2**16-1 := 0;

    signal toggle : std_logic := '0';
    signal uart_rx_data : natural range 0 to 2**16-1;

--------------------------------------------------
begin

--------------------------------------------------
    test_uart : process(clock)
        
    begin
        if rising_edge(clock) then
            init_uart(uart_data_in);
            uart_transmit_counter <= uart_transmit_counter - 1; 
            if uart_transmit_counter = 0 then
                uart_transmit_counter <= counter_at_100khz;
                transmit_16_bit_word_with_uart(uart_data_in, uart_rx_data);

                transmit_counter <= transmit_counter + 1; 
                if transmit_counter = 65535 then
                    transmit_counter <= 3586;
                end if;


            end if;
            receive_data_from_uart(uart_data_out, uart_rx_data);

        end if; --rising_edge
    end process test_uart;	

------------------------------------------------------------------------ 
    uart_clocks <= (clock => system_components_clocks.clock);
    u_uart : uart
    port map( uart_clocks                          ,
    	  system_components_FPGA_in.uart_FPGA_in   ,
    	  system_components_FPGA_out.uart_FPGA_out ,
    	  uart_data_in                             ,
    	  uart_data_out);

------------------------------------------------------------------------ 
    power_supply_control_clocks <= (clock => clock, reset_n => reset_n);
    u_power_supply_control : power_supply_control
    port map( power_supply_control_clocks                          ,
    	  system_components_FPGA_in.power_supply_control_FPGA_in   ,
    	  system_components_FPGA_out.power_supply_control_FPGA_out ,
    	  system_components_data_in.power_supply_control_data_in   ,
    	  system_components_data_out.power_supply_control_data_out); 

------------------------------------------------------------------------ 
end rtl;
