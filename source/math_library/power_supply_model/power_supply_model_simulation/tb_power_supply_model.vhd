LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.lcr_filter_model_pkg.all;
    use math_library.inverter_model_pkg.all;
    use math_library.pi_controller_pkg.all;


entity tb_power_supply_model is
end;

architecture sim of tb_power_supply_model is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50e3;

    signal simulation_counter : natural := 0;

------------------------------------------------------------------------
    -- inverter model signals
    signal duty_ratio : int18 := 15e3;
    signal input_voltage : int18 := 0;
    signal dc_link_voltage : int18 := 0;

    signal dc_link_current : int18 := 0;
    signal dc_link_load_current : int18 := 0;
    signal output_dc_link_load_current : int18 := 0;
    signal output_inverter_load_current : int18 := 0;
    signal output_voltage : int18 := 0;

    signal output_dc_link_voltage : int18 := 0;
    signal output_dc_link_current : int18 := 0;

    --------------------------------------------------
    signal grid_inverter : inverter_model_record := init_inverter_model;
    signal output_inverter : inverter_model_record := init_inverter_model;
    
    signal hw_multiplier1             : multiplier_record := multiplier_init_values;
    signal hw_multiplier2             : multiplier_record := multiplier_init_values;
    signal hw_multiplier3             : multiplier_record := multiplier_init_values;
    signal hw_multiplier4             : multiplier_record := multiplier_init_values;
    signal hw_multiplier5             : multiplier_record := multiplier_init_values;

    signal lcr_filter1 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter2 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter3 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter4 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    signal lcr_filter5 : lcr_model_record := init_lcr_model_integrator_gains(25e3, 2e3);
    --------------------------------------------------
    
    signal inverter_multiplier  : multiplier_record := multiplier_init_values;
    signal inverter_multiplier2 : multiplier_record := multiplier_init_values;
    signal inverter_multiplier3 : multiplier_record := multiplier_init_values;

    signal inverter_simulation_trigger_counter : natural := 0;
    signal inverter_voltage : int18 := 0;

    signal load_resistor_current : int18 := 0;

    signal dab_pi_controller : pi_controller_record := pi_controller_init;
    signal output_resistance : natural  :=50e3;
    signal output_current : integer := 0;

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
    --------------------------------------------------
        impure function "*" ( left, right : int18)
        return int18
        is
        begin
            sequential_multiply(inverter_multiplier, left, right);
            return get_multiplier_result(inverter_multiplier, 15);
        end "*";
    --------------------------------------------------
    begin
        if rising_edge(simulator_clock) then
            ------------------------------------------------------------------------
            simulation_counter <= simulation_counter + 1;
            if simulation_counter = 30e3 then
                -- duty_ratio <= 19e3;
                -- output_resistance <= 5e3;
            end if;

            create_multiplier(hw_multiplier1); 
            create_multiplier(hw_multiplier2); 

            create_inverter_model(grid_inverter , - dab_pi_controller.pi_out , -lcr_filter1.inductor_current.state);
            create_lcr_filter(lcr_filter1       , hw_multiplier1             , grid_inverter.inverter_lc_filter.capacitor_voltage - lcr_filter1.capacitor_voltage.state , lcr_filter1.inductor_current.state - lcr_filter2.inductor_current.state);
            create_lcr_filter(lcr_filter2       , hw_multiplier2             , lcr_filter1.capacitor_voltage.state - lcr_filter2.capacitor_voltage.state                , lcr_filter2.inductor_current.state - 0);


            create_multiplier(hw_multiplier3); 
            create_multiplier(hw_multiplier4); 
            create_inverter_model(output_inverter , dab_pi_controller.pi_out , -lcr_filter3.inductor_current.state);
            create_lcr_filter(lcr_filter3         , hw_multiplier3           , output_inverter.inverter_lc_filter.capacitor_voltage - lcr_filter3.capacitor_voltage , lcr_filter3.inductor_current.state - output_inverter_load_current);


            --------------------------------------------------
            -- output_inverter.inverter_lc_filter.capacitor_voltage.state <= 8e3;
            lcr_filter2.capacitor_voltage.state <= 8e3;

            create_multiplier(inverter_multiplier); 
            create_multiplier(inverter_multiplier2);
            create_pi_controller(inverter_multiplier2, dab_pi_controller, 10e3, 1e3); 

            create_multiplier(inverter_multiplier3);

            inverter_simulation_trigger_counter <= inverter_simulation_trigger_counter + 1;
            if inverter_simulation_trigger_counter = 24 then
                inverter_simulation_trigger_counter <= 0;
                request_inverter_calculation(grid_inverter, duty_ratio);
                request_inverter_calculation(output_inverter, duty_ratio);
                calculate_lcr_filter(lcr_filter1);
                calculate_lcr_filter(lcr_filter2);
                calculate_lcr_filter(lcr_filter3);
                calculate_lcr_filter(lcr_filter4);
                calculate_pi_control(dab_pi_controller, output_inverter.dc_link_voltage - grid_inverter.dc_link_voltage);

            end if; 

            --------------------------------------------------
            sequential_multiply(inverter_multiplier, lcr_filter3.capacitor_voltage.state, output_resistance);
            if multiplier_is_ready(inverter_multiplier) then
                output_inverter_load_current <= get_multiplier_result(inverter_multiplier, 15);
            end if;

            -------------------------------------------------- 
            dc_link_voltage        <= grid_inverter.dc_link_voltage.state;
            output_dc_link_voltage <= output_inverter.dc_link_voltage.state;
            output_dc_link_current <= output_inverter.dc_link_current;
            output_voltage         <= lcr_filter3.capacitor_voltage.state;
            output_current <= output_inverter.inverter_lc_filter.inductor_current.state;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;
