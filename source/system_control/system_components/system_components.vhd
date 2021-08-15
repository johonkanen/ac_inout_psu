library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_components_pkg.all;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;
    use work.mdio_driver_pkg.all;
    use work.ethernet_communication_pkg.all; 
    use work.ethernet_clocks_pkg.all; 
    use work.ethernet_frame_ram_read_pkg.all;
    use work.network_protocol_header_pkg.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.first_order_filter_pkg.all;
    use math_library.lcr_filter_model_pkg.all;

entity system_components is
    port (
        system_clocks                : in  system_clocks_group;
        system_components_FPGA_in    : in  system_components_FPGA_input_group;
        system_components_FPGA_out   : out system_components_FPGA_output_group;
        system_components_FPGA_inout : inout system_components_FPGA_inout_record;
        system_components_data_in    : in  system_components_data_input_group;
        system_components_data_out   : out system_components_data_output_group
    );
end entity system_components;

architecture rtl of system_components is

    alias clock is system_clocks.core_clock;
    alias reset_n is system_clocks.pll_locked;

    signal power_supply_control_clocks   : power_supply_control_clock_group;
    signal power_supply_control_data_in  : power_supply_control_data_input_group;
    signal power_supply_control_data_out : power_supply_control_data_output_group;
    
    signal uart_clocks   : uart_clock_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal uart_transmit_counter : natural range 0 to 2**16-1 := 0;
    constant counter_at_100khz   : natural                    := 120e6/80e3;

    signal uart_rx_data : natural range 0 to 2**16-1;

    signal spi_sar_adc_clocks   : spi_sar_adc_clock_group;
    signal spi_sar_adc_data_in  : spi_sar_adc_data_input_group;
    signal spi_sar_adc_data_out : spi_sar_adc_data_output_group;


    signal test_counter : natural range 0 to 2**16-1;

    signal ethernet_communication_clocks     : ethernet_clock_group;
    signal ethernet_communication_FPGA_in    : ethernet_communication_FPGA_input_group;
    signal ethernet_communication_FPGA_out   : ethernet_communication_FPGA_output_group;
    signal ethernet_communication_FPGA_inout : ethernet_communication_FPGA_inout_record;
    signal ethernet_communication_data_in    : ethernet_communication_data_input_group;
    signal ethernet_communication_data_out   : ethernet_communication_data_output_group;

    alias mdio_driver_data_in  is ethernet_communication_data_in.ethernet_data_in.mdio_driver_data_in;
    alias mdio_driver_data_out is ethernet_communication_data_out.ethernet_data_out.mdio_driver_data_out;
    alias ethernet_data_in is ethernet_communication_data_in.ethernet_data_in;
    alias ethernet_data_out is ethernet_communication_data_out.ethernet_data_out;

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

    signal ram_read_process_counter : natural range 0 to 7 := 0;


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


    constant activate_loopback_at_10MHz : std_logic_vector(15 downto 0) := x"4000";
    constant activate_loopback_at_100MHz : std_logic_vector(15 downto 0) := x"6000";
    constant activate_loopback_at_1000MHz : std_logic_vector(15 downto 0) := x"4140";

    constant force_1000MHz_connection : std_logic_vector(15 downto 0) := x"1140";

    signal shift_register : std_logic_vector(31 downto 0); 
    signal ram_read_controller : ram_reader;

    constant ip_header_offset : natural := 14;
    constant ip_header_length_offset : natural := 0;
    constant ip_encapsulated_protocol : natural := 8;

    signal ram_address_offset : natural range 0 to 2**11-1;

    signal hw_multiplier1             : multiplier_record := multiplier_init_values;
    signal hw_multiplier2             : multiplier_record := multiplier_init_values;
    signal hw_multiplier3             : multiplier_record := multiplier_init_values;
    signal hw_multiplier4             : multiplier_record := multiplier_init_values;
    signal hw_multiplier5             : multiplier_record := multiplier_init_values;
    signal load_current               : int18             := 3000;
    signal input_voltage              : int18             := 2e3;

    signal lcr_filter1 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter2 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter3 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter4 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter5 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);

--------------------------------------------------
begin

    -- system_components_FPGA_out <= (

--------------------------------------------------
    test_with_uart : process(clock)
    --------------------------------------------------
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
                calculate_lcr_filter(lcr_filter1);
                calculate_lcr_filter(lcr_filter2);
                calculate_lcr_filter(lcr_filter3);
                calculate_lcr_filter(lcr_filter4);
                calculate_lcr_filter(lcr_filter5);

                CASE uart_rx_data is
                    WHEN 10 => transmit_16_bit_word_with_uart(uart_data_in, get_filter_output(bandpass_filter.low_pass_filter) );
                    WHEN 11 => transmit_16_bit_word_with_uart(uart_data_in, (bandpass_filter.low_pass_filter.filter_input - get_filter_output(bandpass_filter.low_pass_filter))/2+32768);
                    WHEN 12 => transmit_16_bit_word_with_uart(uart_data_in, get_filter_output(bandpass_filter)/2+32768);
                    WHEN 13 => transmit_16_bit_word_with_uart(uart_data_in, bandpass_filter.low_pass_filter.filter_input - get_filter_output(bandpass_filter));
                    WHEN 14 => transmit_16_bit_word_with_uart(uart_data_in, get_adc_data(spi_sar_adc_data_out));
                    WHEN 15 => transmit_16_bit_word_with_uart(uart_data_in, uart_rx_data);
                    WHEN 16 => transmit_16_bit_word_with_uart(uart_data_in, lcr_filter5.inductor_current.state + 32768);
                    WHEN 17 => transmit_16_bit_word_with_uart(uart_data_in, lcr_filter5.capacitor_voltage.state+ 32768);
                    WHEN others => -- get data from MDIO
                        register_counter := register_counter + 1;
                        if test_counter = 4600 then
                            -- write_data_to_mdio(mdio_driver_data_in, x"00", x"00", activate_loopback_at_1000MHz);
                        else
                            read_data_from_mdio(mdio_driver_data_in, x"00", integer_to_std(register_counter, 8));
                        end if;
                end CASE; 

                filter_data(bandpass_filter, get_square_wave_from_counter(test_counter));
                test_counter <= test_counter + 1; 
                if test_counter = 65535 then
                    test_counter <= 0;
                end if;

                if test_counter = 65536/2 then
                    input_voltage <= -input_voltage;
                end if;
                -- if test_counter = 65535 then
                --     load_resistance <= 5e3;
                -- end if;
            end if;

            if mdio_data_read_is_ready(mdio_driver_data_out) then

                if test_counter < 128+32 then 
                    if test_counter < 128 then
                        ram_read_process_counter <= 0;
                    else
                        transmit_16_bit_word_with_uart(uart_data_in, get_data_from_mdio(mdio_driver_data_out));
                    end if;
                end if; 

            end if;
            
            --------------------------------------------------
            create_ram_read_controller(ethernet_communication_data_in.receiver_ram_read_control_port ,
                                        ethernet_communication_data_out.frame_ram_data_out        ,
                                        ram_read_controller                                       ,
                                        shift_register); 
            --------------------------------------------------
            if protocol_processing_is_ready(ethernet_communication_data_out.ethernet_protocol_data_out) then
                ram_address_offset <= get_frame_address_offset(ethernet_communication_data_out.ethernet_protocol_data_out);
            end if;
            --------------------------------------------------

            CASE ram_read_process_counter is
                WHEN 0 => 

                    load_ram_with_offset_to_shift_register(ram_controller                     => ram_read_controller                 ,
                                                           start_address                      => test_counter*2 + ram_address_offset ,
                                                           number_of_ram_addresses_to_be_read => 2);

                    ram_read_process_counter <= ram_read_process_counter +1;

                WHEN 1 =>
                    if ram_is_buffered_to_shift_register(ram_read_controller) then
                        transmit_16_bit_word_with_uart(uart_data_in, shift_register(15 downto 0)); 
                        ram_read_process_counter <= ram_read_process_counter + 1;
                    end if;

                WHEN others => -- hang here and wait for counter being set to zero
            end CASE;
            -------------------------------------------------- 
            create_multiplier(hw_multiplier1); 
            create_multiplier(hw_multiplier2); 
            create_multiplier(hw_multiplier3); 
            create_multiplier(hw_multiplier4); 
            create_multiplier(hw_multiplier5); 

            create_lcr_filter(lcr_filter1 , hw_multiplier1 , input_voltage                       - lcr_filter1.capacitor_voltage.state , lcr_filter1.inductor_current.state - lcr_filter2.inductor_current.state);
            create_lcr_filter(lcr_filter2 , hw_multiplier2 , lcr_filter1.capacitor_voltage.state - lcr_filter2.capacitor_voltage.state , lcr_filter2.inductor_current.state - lcr_filter3.inductor_current.state);
            create_lcr_filter(lcr_filter3 , hw_multiplier3 , lcr_filter2.capacitor_voltage.state - lcr_filter3.capacitor_voltage.state , lcr_filter3.inductor_current.state - lcr_filter4.inductor_current.state);
            create_lcr_filter(lcr_filter4 , hw_multiplier4 , lcr_filter3.capacitor_voltage.state - lcr_filter4.capacitor_voltage.state , lcr_filter4.inductor_current.state - lcr_filter5.inductor_current.state);
            create_lcr_filter(lcr_filter5 , hw_multiplier5 , lcr_filter4.capacitor_voltage.state - lcr_filter5.capacitor_voltage.state , lcr_filter5.inductor_current.state - load_current);


        end if; --rising_edge
    end process test_with_uart;	

------------------------------------------------------------------------ 
    spi_sar_adc_clocks <= (clock => clock, reset_n => reset_n); 
    u_spi_sar_adc : spi_sar_adc
    port map( spi_sar_adc_clocks                          ,
          system_components_FPGA_in.spi_sar_adc_FPGA_in   ,
    	  system_components_FPGA_out.spi_sar_adc_FPGA_out ,
    	  spi_sar_adc_data_in                             ,
    	  spi_sar_adc_data_out);

------------------------------------------------------------------------ 
    uart_clocks <= (clock => clock);
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
    ethernet_communication_clocks <= (
                                         core_clock => clock, reset_n => '1', 
                                         rx_ddr_clocks => (rx_ddr_clock => system_clocks.ethernet_rx_ddr_clock, reset_n => '1'),
                                         tx_ddr_clocks => (tx_ddr_clock => system_clocks.ethernet_tx_ddr_clock, reset_n => '1')
                                     );

    u_ethernet_communication : ethernet_communication
    port map( ethernet_communication_clocks                              ,
    	  system_components_FPGA_in.ethernet_communication_FPGA_in       ,
    	  system_components_FPGA_out.ethernet_communication_FPGA_out     ,
          system_components_FPGA_inout.ethernet_communication_FPGA_inout ,
    	  ethernet_communication_data_in                                 ,
    	  ethernet_communication_data_out);
------------------------------------------------------------------------ 
end rtl;
