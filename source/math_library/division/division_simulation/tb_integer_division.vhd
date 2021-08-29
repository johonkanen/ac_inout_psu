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
    constant simtime_in_clocks : integer := 100;
------------------------------------------------------------------------
    signal simulation_counter : natural := 1;

    signal hw_multiplier : multiplier_record := multiplier_init_values;
    signal test_multiplier : int18 := 0;
    signal division_process_counter : natural range 0 to 15 := 15;
    signal number_to_be_reciprocated : natural := 32769;
    signal res : natural := 0;
    signal res2 : natural := 0;

------------------------------------------------------------------------
    function get_initial_value_for_division
    (
        divisor : natural
    )
    return natural
    is
    begin
        return 131072-131072/4;
    end get_initial_value_for_division;
------------------------------------------------------------------------

    signal x : natural := get_initial_value_for_division(number_to_be_reciprocated);

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
            return get_multiplier_result(hw_multiplier, 16);
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
                    res2 <= x*(131071 - res);
                    increment_counter_when_ready(hw_multiplier,division_process_counter);
                WHEN 2 =>
                    x <= res2;
                WHEN others => -- wait for start
            end CASE;

        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
end sim;
