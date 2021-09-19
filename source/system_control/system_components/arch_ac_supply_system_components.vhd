architecture ac_power_supply of system_components is

    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;
    use work.ethernet_communication_pkg.all; 
    use work.ethernet_clocks_pkg.all; 
    use work.ethernet_frame_ram_read_pkg.all;
    use work.network_protocol_header_pkg.all;
    use work.mdio_driver_pkg.all;

    use math_library.multiplier_pkg.all;
    use math_library.division_pkg.all;
    use math_library.first_order_filter_pkg.all;
    use math_library.lcr_filter_model_pkg.all;
    use math_library.power_supply_simulation_model_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.sincos_pkg.all;

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

    signal hw_multiplier                : multiplier_record := multiplier_init_values;
    signal output_resistance            : int18             := 12e3;
    signal output_inverter_load_current : int18             := 0;

    signal power_supply_simulation : power_supply_model_record := power_supply_model_init;

    signal grid_duty_ratio : int18 := 15e3;
    signal output_duty_ratio : int18 := 15e3;
    signal output_load_current : int18 := 2e3;

    signal test_leading_zeroes : natural range 0 to 2**15-1;
    signal division_multiplier1 : multiplier_record := init_multiplier;
    signal divider1 : division_record := init_division;
    signal division_multiplier2 : multiplier_record := init_multiplier;
    signal divider2 : division_record := init_division;
    signal division_multiplier3 : multiplier_record := init_multiplier;
    signal divider3 : division_record := init_division;
    signal division_multiplier4 : multiplier_record := init_multiplier;
    signal divider4 : division_record := init_division;
    signal division_multiplier5 : multiplier_record := init_multiplier;
    signal divider5 : division_record := init_division;
    signal division_multiplier6 : multiplier_record := init_multiplier;
    signal divider6 : division_record := init_division;
--------------------------------------------------
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;

    signal sincos_multiplier2 : multiplier_record := init_multiplier;
    signal sincos2 : sincos_record := init_sincos;

    signal sincos_multiplier3 : multiplier_record := init_multiplier;
    signal sincos3 : sincos_record := init_sincos;

    signal sin : int18 := 0;
    signal cos : int18 := 32768;
    signal angle_rad16 : unsigned(15 downto 0) := (others => '0');
--------------------------------------------------
    signal sine_w_harmonics : int18 := 0;
    signal harmonic_process_counter : natural range 0 to 15 := 15;

--------------------------------------------------
begin

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
end ac_power_supply;
