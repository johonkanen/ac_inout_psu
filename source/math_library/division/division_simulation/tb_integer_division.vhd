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
    signal res : natural := 0;
    signal res2 : natural := 0;

    signal divisor_lut_index : natural := 15;
    signal number_to_be_reciprocated : natural := 32767 + divisor_lut_index*1024;
------------------------------------------------------------------------
    function get_lut_index
    (
        number : natural
    )
    return natural
    is

        variable u_number : unsigned(16 downto 0);
        variable lut_index : natural;
    begin 
        u_number  := to_unsigned(number, 17);
        lut_index := to_integer(u_number(14 downto 10));

        return lut_index; 
        
    end get_lut_index;
------------------------------------------------------------------------
    function get_initial_value_for_division
    (
        divisor : natural
    )
    return natural
    is
        type divisor_lut_array is array (integer range 0 to 31) of int18;
        constant divisor_lut : divisor_lut_array := (
          0  => 2**16+2**15+2**14+2**13+2**12+2**11 , 1  => 2**16+2**15+2**14+2**13+2**12 , 2  => 2**16+2**15+2**14+2**13 , 3  => 2**16+2**15+2**14+2**12 , 4  => 2**16+2**15+2**14+2**11 , 5  => 2**16+2**15+2**14       , 6  => 2**16+2**15+2**13+2**12 , 7  => 2**16+2**15+2**13  ,
          8  => 2**16+2**15+2**13                   , 9  => 2**16+2**15+2**12             , 10 => 2**16+2**15             , 11 => 2**16+2**15             , 12 => 2**16+2**14+2**13+2**12 , 13 => 2**16+2**14+2**13+2**11 , 14 => 2**16+2**14+2**13       , 15 => 2**16+2**14+2**13  ,
          16 => 2**16+2**14+2**12                   , 17 => 2**16+2**14+2**11             , 18 => 2**16+2**14+2**11       , 19 => 2**16+2**14             , 20 => 2**16+2**14             , 21 => 2**16+2**13 +2**12      , 22 => 2**16+2**13 +2**12      , 23 => 2**16+2**13 +2**12 ,
          24 => 2**16+2**13                         , 25 => 2**16+2**13                   , 26 => 2**16+2**13             , 27 => 2**16+2**12             , 28 => 2**16+2**12             , 29 => 2**16+2**11             , 30 => 2**16+2**10             , 31 => 2**16);
    begin
        return divisor_lut(get_lut_index(divisor));

    end get_initial_value_for_division;
------------------------------------------------------------------------
    type divider_record is record
        multiplier : multiplier_record;
        division_process_counter : natural range 0 to 3;

        res  : int18;
        res2 : int18;
    end record;

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
        function invert_bits
        (
            number : natural
        )
        return natural
        is
            variable number_in_std_logic : std_logic_vector(16 downto 0);
        begin
            number_in_std_logic := not std_logic_vector(to_unsigned(number,17));
            return to_integer(unsigned(number_in_std_logic));
        end invert_bits;
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
                    res2 <= x*(invert_bits(res));
                    increment_counter_when_ready(hw_multiplier,division_process_counter);
                WHEN 2 =>
                    x <= res2;
                WHEN others => -- wait for start
            end CASE;

        end if; -- rstn
    end process clocked_reset_generator;	

------------------------------------------------------------------------
end sim;
