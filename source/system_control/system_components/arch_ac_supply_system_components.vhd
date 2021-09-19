architecture ac_power_supply of system_components is

    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;
    use work.ethernet_communication_pkg.all; 
    use work.ethernet_clocks_pkg.all; 
    use work.ethernet_frame_ram_read_pkg.all;
    use work.network_protocol_header_pkg.all;
    use work.mdio_driver_pkg.all;

    alias clock is system_clocks.core_clock;
    alias reset_n is system_clocks.pll_locked;

------------------------------------------------------------------------
    signal power_supply_control_data_in  : power_supply_control_data_input_group;
    signal power_supply_control_data_out : power_supply_control_data_output_group;
    
------------------------------------------------------------------------
    signal uart_clocks   : uart_clock_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

------------------------------------------------------------------------
    signal spi_sar_adc_clocks   : spi_sar_adc_clock_group;
    signal spi_sar_adc_data_in  : spi_sar_adc_data_input_group;
    signal spi_sar_adc_data_out : spi_sar_adc_data_output_group;

------------------------------------------------------------------------
    signal ethernet_communication_clocks     : ethernet_clock_group;
    signal ethernet_communication_FPGA_in    : ethernet_communication_FPGA_input_group;
    signal ethernet_communication_FPGA_out   : ethernet_communication_FPGA_output_group;
    signal ethernet_communication_FPGA_inout : ethernet_communication_FPGA_inout_record;
    signal ethernet_communication_data_in    : ethernet_communication_data_input_group;
    signal ethernet_communication_data_out   : ethernet_communication_data_output_group;

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
    u_power_supply_control : power_supply_control
    port map( system_clocks                                            ,
              system_components_FPGA_in.power_supply_control_FPGA_in   ,
              system_components_FPGA_out.power_supply_control_FPGA_out ,
              system_components_data_in.power_supply_control_data_in   ,
              system_components_data_out.power_supply_control_data_out); 

------------------------------------------------------------------------ 
end ac_power_supply;
