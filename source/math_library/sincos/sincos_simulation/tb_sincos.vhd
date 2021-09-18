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
    constant simtime_in_clocks : integer := 5000;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;
    signal hw_multiplier : multiplier_record := init_multiplier;

    signal sincos_process_counter : natural := 15;
    signal angle_rad16 : unsigned(15 downto 0) := (others => '0');

    signal test_reduced_angle : integer := 0;
    signal angle_squared : int18 := 0;
    signal sin16 : int18 := 0;
    signal cos16 : int18 := 32768;
    signal sin : int18 := 0;
    signal cos : int18 := 0;
    signal sincos_is_ready : boolean := false;

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
        variable h0 : int18 := 0;
        variable h1 : int18 := 0;
        variable h2 : int18 := 0;

        variable c0 : int18 := 0;
        variable c1 : int18 := 0;
        variable c2 : int18 := 0;
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_multiplier(hw_multiplier);

            if simulation_counter = 10 or sincos_is_ready then
                sincos_process_counter <= 0;
                angle_rad16 <= angle_rad16 + 511;
            end if; 

            -- using Horners scheme sin = x(1 -(angle_squared*(sinegains(0) - angle_squared*(sinegains(1) - angle_squared*(sinegains(2)))))
            -- h2 <= angle_squared*(sinegains(2));
            -- h1 <= angle_squared*(sinegains(1) - h2);
            -- h0 <= angle_squared*(sinegains(0) - h1);
            -- using Horners scheme cos = 1 - angle_squared*(cosgains(0) - angle_squared*(cosgains(1) - angle_squared*(cosgains(2))));
            sincos_is_ready <= false;
            CASE sincos_process_counter is
                WHEN 0 =>
                    test_reduced_angle <= (to_integer(angle_rad16));
                    multiply(hw_multiplier, angle_reduction(to_integer(angle_rad16)), angle_reduction(to_integer(angle_rad16)));
                    sincos_process_counter <= sincos_process_counter + 1;
                WHEN 1 =>
                    if multiplier_is_ready(hw_multiplier) then
                        angle_squared <=        get_multiplier_result(hw_multiplier, 15);
                        multiply(hw_multiplier,                sinegains(2), get_multiplier_result(hw_multiplier, 15));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 2 =>
                    if multiplier_is_ready(hw_multiplier) then 
                        multiply(hw_multiplier, angle_squared, sinegains(1) - get_multiplier_result(hw_multiplier, 15)); 
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 3 =>
                    if multiplier_is_ready(hw_multiplier) then
                        multiply(hw_multiplier, angle_reduction(test_reduced_angle), sinegains(0) - get_multiplier_result(hw_multiplier, 15)); 
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 4 =>
                    if multiplier_is_ready(hw_multiplier) then
                        sin16 <= get_multiplier_result(hw_multiplier,12);
                        multiply(hw_multiplier, angle_squared, cosgains(2));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 

                WHEN 5 =>
                    if multiplier_is_ready(hw_multiplier) then
                        multiply(hw_multiplier, angle_squared, cosgains(1) - get_multiplier_result(hw_multiplier, 15));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 
                WHEN 6 => 
                    if multiplier_is_ready(hw_multiplier) then
                        cos16 <= cosgains(0) - get_multiplier_result(hw_multiplier, 14);
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 
                WHEN 7 =>
                    sincos_process_counter <= sincos_process_counter + 1;
                    sincos_is_ready <= true;

                    if test_reduced_angle < one_quarter then
                        sin <= sin16;
                        cos <= cos16;
                    elsif test_reduced_angle < three_fourths then
                        sin <= cos16;
                        cos <= -sin16;
                    elsif test_reduced_angle < five_fourths then
                        sin <= -sin16;
                        cos <= -cos16;
                    elsif test_reduced_angle < seven_fourths then
                        sin <= -cos16;
                        cos <= sin16;
                    else
                        sin <= sin16;
                        cos <= cos16;
                    end if;

                when others =>
            end CASE; 
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------ 
end sim;
