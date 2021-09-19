LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.spi_sar_adc_pkg.all;

entity tb_spi_sar_adc is
end;

architecture sim of tb_spi_sar_adc is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 200;

    signal spi_sar_adc_clocks   : spi_sar_adc_clock_group;
    signal spi_sar_adc_FPGA_in  : spi_sar_adc_FPGA_input_group;
    signal spi_sar_adc_FPGA_out : spi_sar_adc_FPGA_output_group;
    signal spi_sar_adc_data_in  : spi_sar_adc_data_input_group;
    signal spi_sar_adc_data_out : spi_sar_adc_data_output_group;

    signal simulation_counter : natural := 0;
    signal spi_adc_is_ready : boolean := false;
    signal spi_clock_out : std_logic;
    signal adc_measurement_data : natural :=0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        wait;
    end process simtime;	

------------------------------------------------------------------------
    sim_clock_gen : process
    begin
        simulator_clock <= '0';
        rstn <= '0';
        simulator_clock <= '0';
        wait for clock_half_per;
        while simulation_running loop
            wait for clock_half_per;
                rstn <= '1';
                simulator_clock <= not simulator_clock;
            end loop;
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rstn = '0' then
        -- reset state
            clocked_reset <= '0';
    
        elsif rising_edge(simulator_clock) then
            clocked_reset <= '1';
    
            simulation_counter <= simulation_counter + 1;

            idle_adc(spi_sar_adc_data_in);
            if simulation_counter = 55 then
                start_ad_conversion(spi_sar_adc_data_in);
            end if;

            spi_adc_is_ready <= ad_conversion_is_ready(spi_sar_adc_data_out);

            if ad_conversion_is_ready(spi_sar_adc_data_out) then
                adc_measurement_data <= get_adc_data(spi_sar_adc_data_out);
            end if;

                             
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

    spi_clock_out <= spi_sar_adc_FPGA_out.spi_clock;
    spi_sar_adc_FPGA_in.spi_serial_data <= '1';

    spi_sar_adc_clocks <= (clock => simulator_clock, reset_n => clocked_reset); 
    u_spi_sar_adc : spi_sar_adc
    port map( spi_sar_adc_clocks,
          spi_sar_adc_FPGA_in,
    	  spi_sar_adc_FPGA_out,
    	  spi_sar_adc_data_in,
    	  spi_sar_adc_data_out);
end sim;
