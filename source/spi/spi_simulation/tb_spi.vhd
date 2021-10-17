LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.spi_adc_pkg.all;
    use work.spi_pkg.all;

entity tb_spi is
end;

architecture sim of tb_spi is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

------------------------------------------------------------------------ 
    signal adc : spi_adc_record := init_spi_Adc;

    signal spi_clock : std_logic;
    signal spi_chip_select_jee : std_logic;

    ------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    simtime : process
    begin
        report "start tb_spi";
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        report "simulation of tb_spi completed";
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
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_spi_adc(adc);

            --------------------------------------------------
            if simulation_counter = 6 then
                request_spi_clock(adc.spi_io_clock_group, 6);
            end if;
            -- if simulation_counter = 34 then
            --     set_clock_division(adc.spi_io_clock_group, 3);
            -- end if;


        end if; -- rising_edge
    end process clocked_reset_generator;	

    spi_clock <= adc.spi_io_clock_group.spi_io_clock;
    spi_chip_select_jee <= adc.spi_cs.spi_chip_select;
------------------------------------------------------------------------
end sim;
