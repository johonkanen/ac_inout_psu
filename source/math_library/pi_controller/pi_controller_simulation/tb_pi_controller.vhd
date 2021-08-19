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
    use math_library.pi_controller_pkg.all;

entity tb_pi_controller is
end;

architecture sim of tb_pi_controller is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 15000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;

    signal hw_multiplier : multiplier_record;
    signal state_variable_multiplier : multiplier_record;

    signal pi_control_process_counter : natural :=0;

    constant kp : natural := 1e5;
    constant ki : natural := 1e4;
    constant pi_controller_radix : natural := 12;
    constant pi_controller_limit : natural := 10e3;

    signal pi_out : int18 := 0;
    signal integrator : int18 := 0;

    signal dc_link_voltege : state_variable_record := (0000, 200);
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
        variable pi_error : int18 := 0;
        variable voltage_reference : int18 := 1000;
        variable load_current : int18 := -8555;
    begin
        if rising_edge(simulator_clock) then

            simulation_counter <= simulation_counter + 1;
            create_multiplier(hw_multiplier);
            create_multiplier(state_variable_multiplier);

            if state_counter = 0 then
                integrate_state(dc_link_voltege, state_variable_multiplier, 15, pi_out - load_current);
                increment_counter_when_ready(state_variable_multiplier, state_counter);
            end if;

            if (simulation_counter + 1250) mod 2500 = 0 then
                load_current := -load_current;
            end if;
            if simulation_counter mod 2500 = 0 then
                -- voltage_reference := -voltage_reference;
            end if;

            if simulation_counter mod 10 = 0 then
                pi_control_process_counter <= 0;
                state_counter <= 0;
            end if; 

            pi_error := voltage_reference - dc_link_voltege.state;
            CASE pi_control_process_counter is
                WHEN 0 =>
                    multiply(hw_multiplier, kp , pi_error);
                    pi_control_process_counter <= pi_control_process_counter + 1;
                WHEN 1 =>
                    multiply(hw_multiplier, ki , pi_error);
                    pi_control_process_counter <= pi_control_process_counter + 1;
                WHEN 2 => 

                    if multiplier_is_ready(hw_multiplier) then
                        pi_control_process_counter <= pi_control_process_counter + 1;
                        pi_out <= integrator + get_multiplier_result(hw_multiplier, pi_controller_radix);
                        if integrator + get_multiplier_result(hw_multiplier, pi_controller_radix) >= pi_controller_limit then
                            pi_out          <= pi_controller_limit;
                            integrator      <= pi_controller_limit - get_multiplier_result(hw_multiplier, pi_controller_radix);
                            pi_control_process_counter <= pi_control_process_counter + 2;
                        end if;

                        if integrator + get_multiplier_result(hw_multiplier, pi_controller_radix) <= -pi_controller_limit then
                            pi_out          <= -pi_controller_limit;
                            integrator      <= -pi_controller_limit - get_multiplier_result(hw_multiplier, pi_controller_radix);
                            pi_control_process_counter <= pi_control_process_counter + 2;
                        end if;
                    end if;
                WHEN 3 =>
                    integrator <= integrator + get_multiplier_result(hw_multiplier, pi_controller_radix);
                    pi_control_process_counter <= pi_control_process_counter + 1;
                WHEN others => -- wait for restart
            end CASE;
            voltage <=pi_error;

    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;
