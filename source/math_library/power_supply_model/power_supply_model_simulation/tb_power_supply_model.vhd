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

------------------------------------------------------------------------
    type grid_inverter_record is record
        grid_inverter : inverter_model_record;
        multiplier1 : multiplier_record;
        multiplier2 : multiplier_record;
        grid_emi_filter_1 : lcr_model_record;
        grid_emi_filter_2 : lcr_model_record;
    end record;

    constant grid_inverter_init : grid_inverter_record := (init_inverter_model, multiplier_init_values, multiplier_init_values,init_lcr_model_integrator_gains(25e3, 2e3), init_lcr_model_integrator_gains(25e3, 2e3));
------------------------------------------------------------------------
    procedure create_grid_inverter
    (
        signal grid_inverter : inout grid_inverter_record;
        ac_load_current : in int18;
        dc_link_load_current : in int18 
    ) is
        alias emi_filter1 is grid_inverter.grid_emi_filter_1;
        alias emi_filter2 is grid_inverter.grid_emi_filter_2;
        alias inverter_lc is grid_inverter.grid_inverter.inverter_lc_filter;
    begin
        create_multiplier(grid_inverter.multiplier1);
        create_multiplier(grid_inverter.multiplier2);
        create_inverter_model(grid_inverter.grid_inverter , dc_link_load_current      , -emi_filter1.inductor_current);
        create_lcr_filter(grid_inverter.grid_emi_filter_1 , grid_inverter.multiplier1 , inverter_lc.capacitor_voltage - emi_filter1.capacitor_voltage , emi_filter1.inductor_current - emi_filter2.inductor_current);
        create_lcr_filter(grid_inverter.grid_emi_filter_2 , grid_inverter.multiplier2 , emi_filter1.capacitor_voltage - emi_filter2.capacitor_voltage , emi_filter2.inductor_current - ac_load_current);

    end create_grid_inverter;

    procedure request_grid_inverter_calculation
    (
        signal grid_inverter : inout grid_inverter_record;
        duty_ratio : in int18
    ) is
    begin
        request_inverter_calculation(grid_inverter.grid_inverter, duty_ratio);
        calculate_lcr_filter(grid_inverter.grid_emi_filter_1);
        calculate_lcr_filter(grid_inverter.grid_emi_filter_2);
    end request_grid_inverter_calculation;

    -- signal grid_inverter_simulation : grid_inverter_record := grid_inverter_init;
    
------------------------------------------------------------------------
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
    signal dab_pi_output : int18 := 0;
    signal dab_pi_error : int18 := 0;

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
    begin
        if rising_edge(simulator_clock) then
            ------------------------------------------------------------------------
            simulation_counter <= simulation_counter + 1;
            if simulation_counter = 30e3 then
                -- duty_ratio <= 19e3;
                output_resistance <= 5e3;
            end if;

            create_multiplier(hw_multiplier1); 
            create_multiplier(hw_multiplier2); 


            -- create_grid_inverter(grid_inverter_simulation, -dab_pi_controller.pi_out, 0);
            create_inverter_model(grid_inverter , - dab_pi_controller.pi_out , -lcr_filter1.inductor_current);
            create_lcr_filter(lcr_filter1       , hw_multiplier1             , grid_inverter.inverter_lc_filter.capacitor_voltage - lcr_filter1.capacitor_voltage, lcr_filter1.inductor_current - lcr_filter2.inductor_current);
            create_lcr_filter(lcr_filter2       , hw_multiplier2             , lcr_filter1.capacitor_voltage- lcr_filter2.capacitor_voltage, lcr_filter2.inductor_current); 

            --------------------------------------------------
            create_multiplier(hw_multiplier3); 
            create_multiplier(hw_multiplier4); 
            create_inverter_model(output_inverter , dab_pi_controller.pi_out , -lcr_filter3.inductor_current);
            create_lcr_filter(lcr_filter3         , hw_multiplier3           , output_inverter.inverter_lc_filter.capacitor_voltage - lcr_filter3.capacitor_voltage , lcr_filter3.inductor_current - output_inverter_load_current); 

            --------------------------------------------------
            grid_inverter.inverter_lc_filter.capacitor_voltage.state <= -8e3;
            -- grid_inverter_simulation.grid_emi_filter_2.capacitor_voltage.state <= -8e3;
            -- grid_inverter_simulation.grid_inverter.dc_link_voltage.state <= 18e3;

            create_multiplier(inverter_multiplier); 
            create_multiplier(inverter_multiplier2);
            create_pi_controller(inverter_multiplier2, dab_pi_controller, 18e3, 2e3); 

            create_multiplier(inverter_multiplier3);

            inverter_simulation_trigger_counter <= inverter_simulation_trigger_counter + 1;
            if inverter_simulation_trigger_counter = 24 then
                inverter_simulation_trigger_counter <= 0;


                calculate_pi_control(dab_pi_controller, output_inverter.dc_link_voltage - grid_inverter.dc_link_voltage);

                -- request_grid_inverter_calculation(grid_inverter_simulation, -duty_ratio);
                request_inverter_calculation(grid_inverter, -duty_ratio);
                calculate_lcr_filter(lcr_filter1);
                calculate_lcr_filter(lcr_filter2);

                -- request_grid_inverter_calculation(grid_inverter_simulation, -duty_ratio);
                request_inverter_calculation(output_inverter, duty_ratio);
                calculate_lcr_filter(lcr_filter3);

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
            output_current         <= output_inverter.inverter_lc_filter.inductor_current.state;
            dab_pi_output          <= dab_pi_controller.pi_out;
            dab_pi_error           <= output_inverter.dc_link_voltage - grid_inverter.dc_link_voltage.state;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;
