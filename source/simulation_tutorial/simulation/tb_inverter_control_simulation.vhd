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
    use math_library.inverter_model_pkg.all;
    use math_library.pi_controller_pkg.all;
 
entity tb_inverter_control_simulation is
end;
 
architecture sim of tb_inverter_control_simulation is
    signal rstn : std_logic;
 
    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 35000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

------------------------------------------------------------------------
    signal sincos_multiplier   : multiplier_record := init_multiplier;
    signal sincos_angle : unsigned(15 downto 0) := (others => '0');
    signal sincos : sincos_record := init_sincos;

------------------------------------------------------------------------ 
    signal inverter_model : inverter_model_record := init_inverter_state_and_gains(
        dc_link_voltage_init          => 25e3 ,
        inductor_integrator_gain      => 20e3 ,
        ac_capacitor_integrator_gain  => 2e3  ,
        dc_link_integrator_gain       => 2e3);

------------------------------------------------------------------------ 
    signal current_pi_control_multiplier : multiplier_record    := init_multiplier;
    signal current_pi_control            : pi_controller_record := init_pi_controller;

    signal voltage_pi_control_multiplier : multiplier_record    := init_multiplier;
    signal voltage_pi_control            : pi_controller_record := init_pi_controller;

------------------------------------------------------------------------ 
    signal sine_output               : int18 := 0;
    signal inverter_output_voltage   : int18 := 0;
    signal inverter_inductor_current : int18 := 0;
    signal duty_ratio                : int18 := 15e3;
    signal load_current              : int18 := 0;
 
------------------------------------------------------------------------
begin
 
------------------------------------------------------------------------
    simtime : process
    begin
        report "start tb_inverter_control_simulation";
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        report "simulation of tb_inverter_control_simulation completed";
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
            --------------------------------------------------
            create_multiplier(sincos_multiplier);
            create_sincos(sincos_multiplier, sincos);

            --------------------------------------------------
            create_multiplier(voltage_pi_control_multiplier);
            create_pi_controller(voltage_pi_control_multiplier, voltage_pi_control, 11200 , 2000);

            create_multiplier(current_pi_control_multiplier);
            create_pi_controller(current_pi_control_multiplier, current_pi_control, 6000 , 800); 

            --------------------------------------------------
            create_inverter_model(inverter_model,dc_link_load_current => 0, load_current => load_current);
            set_dc_link_voltage(inverter_model, 20e3);

            --------------------------------------------------
            -- force output voltage to zero for tuning current control 
            if simulation_counter > 20e3 and simulation_counter < 25e3 then
                inverter_model.inverter_lc_filter.capacitor_voltage.state <= 0;
            end if;

            -- add load current steps
            CASE simulation_counter is
                WHEN 10e3 =>
                    load_current <= -15e3;
                WHEN 15e3 =>
                    load_current <= 15e3;
                WHEN others => -- do nothing
            end CASE;
            --------------------------------------------------
            sincos_angle <= sincos_angle + 25;
            request_sincos(sincos, sincos_angle);

            if simulation_counter mod 25 = 0 then
                request_inverter_calculation(inverter_model, get_pi_control_output(current_pi_control));
                calculate_pi_control(current_pi_control, get_pi_control_output(voltage_pi_control) - get_inverter_inductor_current(inverter_model));
                calculate_pi_control(voltage_pi_control, get_sine(sincos)/4 - get_inverter_capacitor_voltage(inverter_model));
            end if; 

            --------------------------------------------------
            sine_output <= get_sine(sincos);
            inverter_output_voltage <= get_inverter_capacitor_voltage(inverter_model);
            inverter_inductor_current <= get_inverter_inductor_current(inverter_model);
 
        end if; -- rising_edge
    end process clocked_reset_generator;    
------------------------------------------------------------------------
end sim;
