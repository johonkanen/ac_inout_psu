LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.division_pkg.all;

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
    signal hw_multiplier1 : multiplier_record := multiplier_init_values;
    signal test_multiplier : int18 := 0;
    signal division_process_counter : natural range 0 to 15 := 15;
    signal res : natural := 0;
    signal res2 : natural := 0;

    signal divisor_lut_index : natural := 15;
    signal number_to_be_reciprocated : natural := 32767 + divisor_lut_index*1024;

    signal divider : division_record := (0, get_initial_value_for_division(number_to_be_reciprocated), number_to_be_reciprocated,0);

------------------------------------------------------------------------ 

------------------------------------------------------------------------
    signal x : natural := get_initial_value_for_division(number_to_be_reciprocated);
    signal test_leading_zeroes : natural := remove_leading_zeros(2**2 + 12);
------------------------------------------------------------------------
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

            create_multiplier(hw_multiplier);
            create_multiplier(hw_multiplier1);
            create_division(hw_multiplier, divider);

            simulation_counter <= simulation_counter + 1;
            if not division_is_busy(divider) then
                request_division(divider, remove_leading_zeros(9));
            end if; 

        end if; -- rstn
    end process clocked_reset_generator;	
    x <= divider.x;
    division_process_counter <= divider.division_process_counter;


------------------------------------------------------------------------
end sim;
