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


entity tb_inverter_model is
end;

architecture sim of tb_inverter_model is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 25000;

    signal simulation_counter : natural := 0;

------------------------------------------------------------------------
    -- inverter model signals
    signal duty_ratio : int18 := 16384;
    signal input_voltage : int18 := 0;
    signal dc_link_voltage : int18 := 0;

    signal dc_link_current : int18 := 0;
    signal dc_link_load_current : int18 := 0;
    signal load_current : int18 := 0;

    signal grid_inverter : inverter_model_record := init_inverter_model;
    
    signal inverter_multiplier : multiplier_record     := multiplier_init_values;
    signal inverter_multiplier2 : multiplier_record     := multiplier_init_values;
    signal grid_inverter_state_counter : natural range 0 to 7;

    signal inverter_simulation_trigger_counter : natural := 0;
    signal inverter_voltage : int18 := 0;

    signal load_resistor_current : int18 := 0;

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

            create_multiplier(inverter_multiplier);
            create_multiplier(inverter_multiplier2);
            create_inverter_model(grid_inverter, dc_link_load_current, 0);

            inverter_simulation_trigger_counter <= inverter_simulation_trigger_counter + 1;
            if inverter_simulation_trigger_counter = 36 then
                inverter_simulation_trigger_counter <= 0;
                grid_inverter_state_counter <= 0;
                request_inverter_calculation(grid_inverter, 32768/4);
            end if;


            grid_inverter.inverter_lc_filter.capacitor_voltage.state <= 10e3;

            sequential_multiply(inverter_multiplier2, grid_inverter.dc_link_voltage.state, 20e3);
            if multiplier_is_ready(inverter_multiplier2) then
                dc_link_load_current <= get_multiplier_result(inverter_multiplier2, 15);
            end if;

            dc_link_voltage <= grid_inverter.dc_link_voltage.state;
            load_current <=  grid_inverter.inverter_lc_filter.capacitor_voltage.state * 20e3;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;
