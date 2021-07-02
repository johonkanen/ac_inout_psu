library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_components_pkg.all;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;
    use work.mdio_driver_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.first_order_filter_pkg.all;

entity system_components is
    port (
        system_components_clocks   : in  system_components_clock_group;
        system_components_FPGA_in  : in  system_components_FPGA_input_group;
        system_components_FPGA_out : out system_components_FPGA_output_group;
        system_components_FPGA_inout : inout system_components_FPGA_inout_record;
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


    signal test_counter : natural range 0 to 2**16-1;

    signal mdio_driver_clocks   : mdio_driver_clock_group;
    signal mdio_driver_data_in  : mdio_driver_data_input_group;
    signal mdio_driver_data_out : mdio_driver_data_output_group; 

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
    -- multiplier instantiation
    signal multiplier : multiplier_record;
    -- filter instantiation
    signal low_pass_filter : first_order_filter := init_filter_state;
    signal low_pass_filter2 : first_order_filter := init_filter_state;

------------------------------------------------------------------------
    type bandpass_filter_record is record
        high_pass_filter : first_order_filter;
        low_pass_filter : first_order_filter;
        multiplier : multiplier_record;
    end record;

------------------------------------------------------------------------
    procedure create_bandpass_filter
    (
        signal bandpass_filter : inout bandpass_filter_record
    ) is
    begin
        create_multiplier(bandpass_filter.multiplier);
        create_first_order_filter(bandpass_filter.low_pass_filter, bandpass_filter.multiplier, 450, 3e2);
        create_first_order_filter(bandpass_filter.high_pass_filter, bandpass_filter.multiplier, 1500, 3200);
        if filter_is_ready(bandpass_filter.low_pass_filter) then
            filter_data(bandpass_filter.high_pass_filter, bandpass_filter.low_pass_filter.filter_input - get_filter_output(bandpass_filter.low_pass_filter));
        end if; 
    end create_bandpass_filter;

------------------------------------------------------------------------
    procedure filter_data
    (
        signal bandpass_filter : inout bandpass_filter_record;
        data_to_filter : in int18
    ) is
    begin
        filter_data(bandpass_filter.low_pass_filter, data_to_filter);
        
    end filter_data;

    function get_filter_output
    (
        bandpass_filter : bandpass_filter_record
    )
    return integer
    is
    begin
        return get_filter_output(bandpass_filter.high_pass_filter);
    end get_filter_output;

    signal bandpass_filter : bandpass_filter_record;
    signal data_from_mdio : std_logic_vector(15 downto 0);
    signal mdio_register_counter : natural range 0 to 31;


    procedure increment
    (
        signal counter : inout integer
    ) is
    begin
        counter <= counter + 1;
        
    end increment;

    signal mmd_read_access_counter : natural range 0 to 7;
    signal mmd_is_busy : boolean;


    type std_array is array (integer range 0 to 31) of std_logic_vector(15 downto 0);
    signal mdio_registers : std_array;

--------------------------------------------------
begin

--------------------------------------------------
    test_with_uart : process(clock)

        --------------------------------------------------
        function get_square_wave_from_counter
        (
            counter_value : integer
        )
        return int18
        is
        begin
            if counter_value > 32767 then
                return 55e3;
            else
                return 15e3;
            end if;
        end get_square_wave_from_counter;
        --------------------------------------------------

        variable register_counter : natural range 0 to 31 := 0;
        
    begin
        if rising_edge(clock) then

            create_bandpass_filter(bandpass_filter);

            init_mdio_driver(mdio_driver_data_in);

            idle_adc(spi_sar_adc_data_in);
            init_uart(uart_data_in);
            receive_data_from_uart(uart_data_out, uart_rx_data);
            system_components_FPGA_out.test_ad_mux <= integer_to_std(number_to_be_converted => uart_rx_data, bits_in_word => 3);

            uart_transmit_counter <= uart_transmit_counter - 1; 
            if uart_transmit_counter = 0 then
                uart_transmit_counter <= counter_at_100khz;
                start_ad_conversion(spi_sar_adc_data_in); 
            end if; 

            if ad_conversion_is_ready(spi_sar_adc_data_out) then

                CASE uart_rx_data is
                    WHEN 10 => transmit_16_bit_word_with_uart(uart_data_in, get_filter_output(bandpass_filter.low_pass_filter) );
                    WHEN 11 => transmit_16_bit_word_with_uart(uart_data_in, (bandpass_filter.low_pass_filter.filter_input - get_filter_output(bandpass_filter.low_pass_filter))/2+32768);
                    WHEN 12 => transmit_16_bit_word_with_uart(uart_data_in, get_filter_output(bandpass_filter)/2+32768);
                    WHEN 13 => transmit_16_bit_word_with_uart(uart_data_in, bandpass_filter.low_pass_filter.filter_input - get_filter_output(bandpass_filter));
                    WHEN 14 => transmit_16_bit_word_with_uart(uart_data_in, get_adc_data(spi_sar_adc_data_out));
                    WHEN 15 => transmit_16_bit_word_with_uart(uart_data_in, uart_rx_data);
                    WHEN others => -- get data from MDIO
                        register_counter := register_counter + 1;
                        read_data_from_mdio(mdio_driver_data_in, x"00", integer_to_std(register_counter, 8));
                end CASE;



                filter_data(bandpass_filter, get_square_wave_from_counter(test_counter));
                test_counter <= test_counter + 1; 
                if test_counter = 65535 then
                    test_counter <= 0;
                end if;
            end if;

            if mdio_data_read_is_ready(mdio_driver_data_out) then
                mdio_registers(register_counter) <=  get_data_from_mdio(mdio_driver_data_out);

                if test_counter < 32 then
                    transmit_16_bit_word_with_uart(uart_data_in, get_data_from_mdio(mdio_driver_data_out));
                end if;
            end if;

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
    mdio_driver_clocks <= (clock => clock);
    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        system_components_FPGA_out.mdio_driver_FPGA_out ,
        system_components_FPGA_inout.mdio_driver_FPGA_inout ,
        mdio_driver_data_in  ,
        mdio_driver_data_out);

------------------------------------------------------------------------ 
end rtl;
