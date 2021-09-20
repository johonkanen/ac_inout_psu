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
    constant simtime_in_clocks : integer := 45000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

    signal output_inverter : inverter_model_record := init_inverter_state_and_gains(
                                                        dc_link_voltage_init         => 15e3 ,
                                                        inductor_integrator_gain     => 25e3  ,
                                                        ac_capacitor_integrator_gain => 20e2 ,
                                                        dc_link_integrator_gain      => 1000);
    
    signal grid_inductor_multiplier : multiplier_record := init_multiplier;

    signal lcr_filter_multiplier : multiplier_record := init_multiplier;
    signal test_lcr : lcr_model_record := init_lcr_model_integrator_gains(10e3, 1e3);
    -- signal output_inverter : inverter_model_record := init_inverter_model;
    signal output_inverter_voltage : int18 := 0;
    signal output_inverter_current : int18 := 0;
    signal multiplier : multiplier_record := init_multiplier;
    signal load_resistance : int18 := 0;
    signal radix15_duty : int18 := 15e3;
    signal load_current : int18 := 0;

    signal input_dc_link_voltage : int18 := 15e3;
    signal control_multiplier : multiplier_record := init_multiplier;
    signal current_pi_controller : pi_controller_record := init_pi_controller;
    signal voltage_pi_controller : pi_controller_record := init_pi_controller;

    signal prbs17 : std_logic_vector(16 downto 0) := (others => '1');

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
            create_inverter_model(output_inverter, 100, get_multiplier_result(multiplier, 15) + load_current);
            output_inverter.dc_link_voltage.state <= input_dc_link_voltage;

            create_multiplier(control_multiplier);
            create_pi_controller(control_multiplier, current_pi_controller, 5e3, 2e2);
            create_pi_controller(control_multiplier, voltage_pi_controller, 13e3, 35e2);

            CASE simulation_counter is
                WHEN 0 =>
                    input_dc_link_voltage <= 20e3;
                WHEN 13e3 =>
                    load_resistance <= 55e3;
                WHEN 21e3 =>
                    input_dc_link_voltage <= 10e3;
                WHEN 27e3 =>
                    load_current <= 5e3;
                WHEN others =>
            end CASE;

            create_multiplier(multiplier);
            if simulation_counter mod 25 = 0 then 
                request_inverter_calculation(output_inverter, get_pi_control_output(current_pi_controller));
                calculate_pi_control(current_pi_controller, get_pi_control_output(voltage_pi_controller) - get_inverter_inductor_current(output_inverter) + to_integer(signed(prbs17))/2**9);
            end if;
            if pi_control_calculation_is_ready(current_pi_controller) then
                calculate_pi_control(voltage_pi_controller, 2e3 - get_inverter_capacitor_voltage(output_inverter));
            end if;

            sequential_multiply(multiplier, get_inverter_capacitor_voltage(output_inverter), -load_resistance); 

            --- plot measurements
            prbs17 <= prbs17(15 downto 0) & prbs17(16);
            prbs17(14) <= prbs17(16) xor prbs17(13);

            --- plot measurements
            output_inverter_voltage <= get_inverter_capacitor_voltage(output_inverter);
            output_inverter_current <= get_inverter_inductor_current(output_inverter);
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
end sim;
