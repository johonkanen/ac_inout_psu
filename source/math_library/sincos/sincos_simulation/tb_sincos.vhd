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

entity tb_sincos is
end;

architecture sim of tb_sincos is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;
    signal hw_multiplier : multiplier_record := init_multiplier;

    signal sincos_process_counter : natural := 15;
    signal angle_rad16 : natural := 0;

    signal test_reduced_angle : natural := 0;
    signal angle_squared : int18 := 0;
    signal h0 : int18 := 0;
    signal h1 : int18 := 0;
    signal h2 : int18 := 0;

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
            report "sincos finished";
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            angle_rad16 <= angle_rad16 + 512;

            create_multiplier(hw_multiplier);

            if simulation_counter = 10 then
                sincos_process_counter <= 0;
            end if; 

            -- using hohners scheme x(1 -(angle_squared*sinegains(0) - angle_squared*(sinegains(1) - angle_squared*(sinegains(0))));
            -- h2 <= angle_squared*(sinegains(2));
            -- h1 <= angle_squared*(sinegains(1) - h2);
            -- h0 <= angle_squared*(sinegains(0) - h1);
            CASE sincos_process_counter is
                WHEN 0 =>
                    test_reduced_angle <= angle_reduction(angle_rad16);
                    multiply(hw_multiplier, angle_reduction(angle_rad16), angle_reduction(angle_rad16));
                    sincos_process_counter <= sincos_process_counter + 1;
                WHEN 1 =>
                    if multiplier_is_ready(hw_multiplier) then
                        angle_squared <= get_multiplier_result(hw_multiplier, 18);
                        multiply(hw_multiplier, get_multiplier_result(hw_multiplier, 18), sinegains(2));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 2 =>
                    if multiplier_is_ready(hw_multiplier) then
                        h2 <= get_multiplier_result(hw_multiplier, 12);
                        multiply(hw_multiplier, angle_squared, sinegains(2)); 
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 3 =>
                    if multiplier_is_ready(hw_multiplier) then
                        multiply(hw_multiplier, angle_squared, sinegains(1) - get_multiplier_result(hw_multiplier, 12)); 
                        h1 <= sinegains(1) - get_multiplier_result(hw_multiplier, 12);
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 4 =>
                    if multiplier_is_ready(hw_multiplier) then
                        h0 <= sinegains(0) - get_multiplier_result(hw_multiplier, 12);
                        report "angle squared is " & integer'image(sinegains(0) - get_multiplier_result(hw_multiplier, 12));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);

                when others =>
            end CASE;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------ 
end sim;
