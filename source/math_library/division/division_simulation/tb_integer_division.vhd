LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;

entity tb_integer_division is
end;

architecture sim of tb_integer_division is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 550;
------------------------------------------------------------------------
    signal simulation_counter : natural := 1;

    signal hw_multiplier : multiplier_record := multiplier_init_values;
    signal test_multiplier : int18 := 0;
    signal division_process_counter : natural range 0 to 15 := 15;
    constant initial_value : natural := 22175;
    signal x : natural := initial_value;
    signal number_to_be_reciprocated : natural := 22175;
    signal res : natural := 0;
    signal res2 : natural := 0;

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
            sequential_multiply(hw_multiplier, left, right);
            return get_multiplier_result(hw_multiplier, 15);
        end "*";
    --------------------------------------------------
    begin
        if rising_edge(simulator_clock) then

            simulation_counter <= simulation_counter + 1;
            create_multiplier(hw_multiplier);

            if simulation_counter mod 5  = 0 then
                division_process_counter <= 0;
            end if;

            CASE division_process_counter is
                WHEN 0 =>
                    res <= number_to_be_reciprocated * x;
                    increment_counter_when_ready(hw_multiplier,division_process_counter);
                WHEN 1 =>
                    res2 <= x*(65536 - res);
                    increment_counter_when_ready(hw_multiplier,division_process_counter);
                WHEN 2 =>
                    x <= res2;
                    division_process_counter <= division_process_counter + 1;
                WHEN 3 =>
                    division_process_counter <= division_process_counter + 1;
                WHEN 4 =>
                    division_process_counter <= division_process_counter + 1;
                WHEN others => -- wait for start
            end CASE;

        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
end sim;
