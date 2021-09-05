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
    signal division_process_counter : natural range 0 to 15 := 15;

    signal divisor_lut_index : natural := 15;
    signal number_to_be_reciprocated : natural := 32767 + divisor_lut_index*1024;

    signal divider : division_record := init_division;

------------------------------------------------------------------------ 

    signal division_result : int18 := 0;
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
        -- impure function "*" ( left, right : int18)
        -- return int18
        -- is
        -- begin
        --     sequential_multiply(hw_multiplier, left, right);
        --     return get_multiplier_result(hw_multiplier, 16);
        -- end "*";
    --------------------------------------------------
        constant test_divident : natural := 800;
        constant test_divider : natural  := 800;
        constant result_radix : natural  := 15;
    begin
        if rising_edge(simulator_clock) then

            create_multiplier(hw_multiplier);
            create_multiplier(hw_multiplier1);
            create_division(hw_multiplier, divider);

            simulation_counter <= simulation_counter + 1;
            -- if simulation_counter mod 20  = 0 then
            if simulation_counter = 10 then
                request_division(divider, test_divident, test_divider);
            end if; 

            if division_is_ready(hw_multiplier, divider) then
                if test_divider < 16384 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**1;
                end if;
                if test_divider < 8192 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**2;
                end if ;
                if test_divider < 4096 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**3;
                end if ;
                if test_divider < 2048 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**4;
                end if ;
                if test_divider < 1024 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**5;
                end if ;
                if test_divider < 512 then
                    division_result <= (get_multiplier_result(hw_multiplier,16))*2**6;
                end if ;
            end if;

        end if; -- rstn
    end process clocked_reset_generator;	

------------------------------------------------------------------------
end sim;
