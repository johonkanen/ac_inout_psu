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

entity tb_pi_controller is
end;

architecture sim of tb_pi_controller is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 5000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

    signal hw_multiplier : multiplier_record;
    signal state_variable_multiplier : multiplier_record;

    signal process_counter : natural :=0;

    constant kp : natural := 1e4;
    constant ki : natural := 1e3;

    signal pi_out : int18 := 0;
    signal integrator : int18 := 0;

    signal dc_link_voltege : state_variable_record := init_state_variable_gain(20000);
    signal voltage : int18 := 0;

    signal state_counter : natural := 0;

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
        variable pi_error : int18 := 500;
    begin
        if rising_edge(simulator_clock) then

            simulation_counter <= simulation_counter + 1;
            create_multiplier(hw_multiplier);
            create_multiplier(state_variable_multiplier);

            CASE state_counter is
                WHEN 0 =>
                    integrate_state(dc_link_voltege, state_variable_multiplier, 15, pi_out);
                    increment_counter_when_ready(state_variable_multiplier, state_counter);
                WHEN others => -- wait for 0
            end CASE;


            if simulation_counter mod 10 = 0 then
                process_counter <= 0;
                state_counter <= 0;
            end if; 

            pi_error := 2500 - dc_link_voltege.state;
            CASE process_counter is
                WHEN 0 =>
                    multiply(hw_multiplier, kp , pi_error);
                    process_counter <= process_counter + 1;
                WHEN 1 =>
                    multiply(hw_multiplier, ki , pi_error);
                    process_counter <= process_counter + 1;
                WHEN 2 => 

                    if multiplier_is_ready(hw_multiplier) then
                        process_counter <= process_counter + 1;
                        pi_out <= integrator + get_multiplier_result(hw_multiplier, 15);
                        if pi_out + get_multiplier_result(hw_multiplier, 15) > 10e3 then
                            pi_out <= 10e3;
                            integrator <= 10e3 - pi_out;
                            process_counter <= process_counter + 2;
                        end if;

                        if pi_out + get_multiplier_result(hw_multiplier, 15) < -10e3 then
                            pi_out <= -10e3;
                            integrator <= 10e3 - pi_out;
                            process_counter <= process_counter + 2;
                        end if;
                    end if;
                WHEN 3 =>
                    integrator <= integrator + get_multiplier_result(hw_multiplier, 15);
                    process_counter <= process_counter + 1;
                WHEN others => -- wait for restart
            end CASE;

    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    voltage <= dc_link_voltege.state;

end sim;
