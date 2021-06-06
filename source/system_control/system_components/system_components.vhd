library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_components_pkg.all;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;

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

    signal uart_rx_data : natural range 0 to 2**16-1;

    signal spi_sar_adc_clocks   : spi_sar_adc_clock_group;
    signal spi_sar_adc_data_in  : spi_sar_adc_data_input_group;
    signal spi_sar_adc_data_out : spi_sar_adc_data_output_group;

    signal adc_data : natural range 0 to 2**16-1 := 0;

    signal multiplier_clocks   : multiplier_clock_group;
    signal multiplier_data_in  : multiplier_data_input_group;
    signal multiplier_data_out : multiplier_data_output_group;
    
    constant b0 : int18 := 50;
    constant b1 : int18 := 3e2;
    constant a1 : int18 := 2**17-1-b1-b0;

    signal filter_output : int18 := 0;
    signal filter_memory : int18 := 0;

    signal filter_is_triggered : boolean;
    signal filter_counter : natural range 0 to 15 := 0;

    signal test_counter : natural range 0 to 2**16-1;

    function integer_to_std
    (
        number_to_be_converted : integer;
        bits_in_word : integer
    )
    return std_logic_vector
    is
    begin
        return std_logic_vector(to_unsigned(number_to_be_converted,bits_in_word));

        
    end integer_to_std;



--------------------------------------------------
begin

--------------------------------------------------
    multiplier_clocks <= (clock => system_components_clocks.clock);
    u_multiplier : multiplier
    port map( multiplier_clocks ,
    	  multiplier_data_in    ,
    	  multiplier_data_out); 

--------------------------------------------------
    test_with_uart : process(clock)
        
    begin
        if rising_edge(clock) then

            init_multiplier(multiplier_data_in);

            idle_adc(spi_sar_adc_data_in);
            init_uart(uart_data_in);
            uart_transmit_counter <= uart_transmit_counter - 1; 
            if uart_transmit_counter = 0 then
                uart_transmit_counter <= counter_at_100khz;
                start_ad_conversion(spi_sar_adc_data_in);

            end if;

            system_components_FPGA_out.test_ad_mux <= integer_to_std(number_to_be_converted => uart_rx_data, bits_in_word => 3);
            filter_is_triggered <= false;
            receive_data_from_uart(uart_data_out, uart_rx_data);
            if ad_conversion_is_ready(spi_sar_adc_data_out) then
                test_counter <= test_counter + 1;
                filter_is_triggered <= true;
                adc_data <= get_adc_data(spi_sar_adc_data_out);
                CASE uart_rx_data is
                    WHEN 10 => transmit_16_bit_word_with_uart(uart_data_in, filter_output );
                    WHEN 11 => transmit_16_bit_word_with_uart(uart_data_in, (adc_data + get_adc_data(spi_sar_adc_data_out))/2);
                    WHEN 12 => transmit_16_bit_word_with_uart(uart_data_in, get_adc_data(spi_sar_adc_data_out)); 
                    WHEN 13 => transmit_16_bit_word_with_uart(uart_data_in, get_adc_data(spi_sar_adc_data_out));
                    WHEN 14 => transmit_16_bit_word_with_uart(uart_data_in, test_counter);
                    WHEN others =>  transmit_16_bit_word_with_uart(uart_data_in, uart_rx_data); 
                end CASE;
            end if;

            if filter_is_triggered then
                filter_counter <= 0;
            end if;

            CASE filter_counter is
                WHEN 0 =>
                    multiply(multiplier_data_in, test_counter, b0);
                    filter_counter <= filter_counter + 1;

                WHEN 1 =>
                    multiply(multiplier_data_in, test_counter, b1);
                    filter_counter <= filter_counter + 1;

                WHEN 2 =>
                    filter_counter <= filter_counter + 1;
                    multiply(multiplier_data_in, 0, 0);

                WHEN 3 =>
                    filter_counter <= filter_counter + 1;

                WHEN 4 =>
                    filter_output <= filter_memory + get_multiplier_result(multiplier_data_out, 17);
                    multiply(multiplier_data_in, filter_output, a1);
                    filter_counter <= filter_counter + 1;
                    
                WHEN 5 =>
                    filter_memory <= get_multiplier_result(multiplier_data_out, 17);
                    filter_counter <= filter_counter + 1;

                WHEN 6 =>
                    filter_counter <= filter_counter + 1;

                WHEN 7 =>
                    filter_counter <= filter_counter + 1;

                when 8 =>
                    filter_memory <= filter_memory + get_multiplier_result(multiplier_data_out, 17);
                    filter_counter <= filter_counter + 1;

                WHEN others => -- do nothing
            end CASE; 

        end if; --rising_edge
    end process test_with_uart;	

------------------------------------------------------------------------ 
    spi_sar_adc_clocks <= (clock => system_components_clocks.clock, reset_n => reset_n); 
    u_spi_sar_adc : spi_sar_adc
    port map( spi_sar_adc_clocks                          ,
          system_components_FPGA_in.spi_sar_adc_FPGA_in   ,
    	  system_components_FPGA_out.spi_sar_adc_FPGA_out ,
    	  spi_sar_adc_data_in                             ,
    	  spi_sar_adc_data_out);

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
