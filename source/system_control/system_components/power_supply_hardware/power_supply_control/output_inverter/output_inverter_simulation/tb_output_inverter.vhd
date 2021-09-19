LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.division_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.pi_controller_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.inverter_model_pkg.all;
    use math_library.lcr_filter_model_pkg.all;

entity tb_output_inverter is
end;

architecture sim of tb_output_inverter is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

    signal inverter_model : inverter_model_record := init_inverter_state_and_gains(
                                                        dc_link_voltage_init         => 15e3 ,
                                                        inductor_integrator_gain     => 3e2  ,
                                                        ac_capacitor_integrator_gain => 20e3 ,
                                                        dc_link_integrator_gain      => 1000);
    
    signal grid_inductor_multiplier : multiplier_record := init_multiplier;

    signal lcr_filter_multiplier : multiplier_record := init_multiplier;
    signal test_lcr : lcr_model_record := init_lcr_model_integrator_gains(10e3, 1e3);

begin

------------------------------------------------------------------------
    simtime : process
    begin
        report "simulate output inverter control";
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        report "output inverter control simulation ready";
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

            create_lcr_filter(test_lcr,lcr_filter_multiplier, 0, 0 );

    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
end sim;
