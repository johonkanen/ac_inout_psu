LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;

entity lrc_model is
end;

architecture sim of lrc_model is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 25000;

    signal simulation_counter : natural := 0;
    signal multiplier_output : signed(35 downto 0);
    signal multiplier_is_ready_when_1 : std_logic;
    signal int18_multiplier_output : int18 := 0;

    signal hw_multiplier : multiplier_record := multiplier_init_values;
------------------------------------------------------------------------
    signal shift_register : std_logic_vector(2 downto 0);

    signal signal_multiplier_is_ready : boolean := false;
    -- lrc model signals
    signal inductor_current : int18  := 0;
    signal capacitor_voltage : int18 := 0;
    signal input_voltage : int18     := -2500;
    signal capacitor_delta : int18   := 0;

    signal inductor_current_delta : int18 := 0;

    signal inductor_integrator_gain : int18 := 25e3;
    signal capacitor_integrator_gain : int18 := 10000;
    signal load_resistance : int18 := 500;

    signal inductor_series_resistance : int18 := 25e2;

    signal load_current : int18 := 5000;

    signal process_counter : natural := 0;

    signal simulation_trigger_counter : natural := 0;
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
        if rising_edge(simulator_clock) then

            create_multiplier(hw_multiplier); 
            simulation_counter <= simulation_counter + 1;

            simulation_trigger_counter <= simulation_trigger_counter + 1;
            if simulation_trigger_counter = 19 then
                simulation_trigger_counter <= 0;
                process_counter <= 0;
            end if;

            if simulation_counter  mod 6725 = 0 then
                load_current <= -load_current;
            end if;

            CASE process_counter is 
                WHEN 0 => 
                    sequential_multiply(hw_multiplier, inductor_series_resistance, inductor_current);
                    if multiplier_is_ready(hw_multiplier) then
                        inductor_current_delta <= get_multiplier_result(hw_multiplier, 15);
                        process_counter <= process_counter + 1;
                    end if;

                WHEN 1 => 
                    sequential_multiply(hw_multiplier, inductor_integrator_gain, input_voltage - capacitor_voltage); 
                    if multiplier_is_ready(hw_multiplier) then
                        inductor_current <= get_multiplier_result(hw_multiplier, 15) + inductor_current - inductor_current_delta;
                        process_counter <= process_counter + 1;
                    end if;
                WHEN 2 => 
                    sequential_multiply(hw_multiplier, load_resistance, capacitor_voltage); 
                    if multiplier_is_ready(hw_multiplier) then
                        capacitor_delta <= get_multiplier_result(hw_multiplier, 17);
                        process_counter <= process_counter + 1;
                    end if;

                WHEN 3 =>
                    sequential_multiply(hw_multiplier, capacitor_integrator_gain, inductor_current - load_current);
                    if multiplier_is_ready(hw_multiplier) then
                        capacitor_voltage <= capacitor_voltage + get_multiplier_result(hw_multiplier, 15) - capacitor_delta;
                        process_counter <= process_counter + 1;
                    end if;
                WHEN others => -- do nothing
            end CASE; 

            -- if multiplier_is_ready(hw_multiplier) then
            --     report "multiplication result at simulation_counter value " & integer'image(simulation_counter)  &" : " & integer'image(inductor_current);
            -- end if; 

        end if; -- rstn
    end process clocked_reset_generator;	

    process(hw_multiplier)
    begin
        signal_multiplier_is_ready <= hw_multiplier.multiplier_is_busy;
        shift_register <= hw_multiplier.shift_register;
    end process;
------------------------------------------------------------------------
end sim;
