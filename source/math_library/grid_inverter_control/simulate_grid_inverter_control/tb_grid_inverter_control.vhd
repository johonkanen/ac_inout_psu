LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.sincos_pkg.all;
    use math_library.pi_controller_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.inverter_model_pkg.all;

entity tb_grid_inverter_control is
end;

architecture sim of tb_grid_inverter_control is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 15000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;


    --------------------------------------------------
    -- grid voltage
    signal sincos_multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos; 
    signal sincos_angle : unsigned(15 downto 0) := (others => '0'); 

    --------------------------------------------------
    -- inverter model
    signal inverter_model : inverter_model_record := init_inverter_model;
    
    signal grid_inductor_multiplier : multiplier_record := init_multiplier;
    -- inductor = 2^radix*ts/gain = 13uh for grid
    signal grid_inductor : state_variable_record := init_state_variable_gain(50000);

    --------------------------------------------------
    -- controller
    signal multiplier : multiplier_record := init_multiplier; 
    signal pi_controller : pi_controller_record := init_pi_controller; 
    --------------------------------------------------
    signal sine : int18 := 0;
    signal grid_current : int18 := 0;

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
            report "grid inverter control simulation finished";
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rising_edge(simulator_clock) then
            --------------------------------------------------
            simulation_counter <= simulation_counter + 1;
            --------------------------------------------------
            create_multiplier(sincos_multiplier);
            create_sincos(sincos_multiplier, sincos); 

            if sincos_is_ready(sincos) or simulation_counter = 0 then
                sincos_angle <= sincos_angle + 300;
                request_sincos(sincos, sincos_angle);
                request_state_variable_calculation(grid_inductor);
                request_inverter_calculation(inverter_model,0);
            end if;

            --------------------------------------------------
            create_multiplier(grid_inductor_multiplier); 
            create_state_variable(grid_inductor, grid_inductor_multiplier, get_sine(sincos)/256);
            create_inverter_model(inverter_model, 500, grid_inductor.state);
            --------------------------------------------------
            create_multiplier(multiplier); 
    
            --------------------------------------------------
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    sine <= sincos.sin;
    grid_current <= grid_inductor.state;

end sim;
