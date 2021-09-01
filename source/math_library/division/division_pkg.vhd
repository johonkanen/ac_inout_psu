library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

package division_pkg is
--------------------------------------------------
    type division_record is record
        division_process_counter : natural range 0 to 3;
        res : int18;
        res2 : int18;
        x: int18;
        number_to_be_reciprocated : int18;
    end record;

    constant init_division : division_record := (3, 0, 0, 0, 0);

    procedure create_division (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record);

    function get_initial_value_for_division ( divisor : natural)
        return natural;

end package division_pkg;


package body division_pkg is

------------------------------------------------------------------------
    function get_initial_value_for_division
    (
        divisor : natural
    )
    return natural

    is
    --------------------------------------------------
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
    -------------------------------------------------- 
        type divisor_lut_array is array (integer range 0 to 31) of int18;
        constant divisor_lut : divisor_lut_array := (
          0  => 2**16+2**15+2**14+2**13+2**12+2**11 , 1  => 2**16+2**15+2**14+2**13+2**12 , 2  => 2**16+2**15+2**14+2**13 , 3  => 2**16+2**15+2**14+2**12 , 4  => 2**16+2**15+2**14+2**11 , 5  => 2**16+2**15+2**14       , 6  => 2**16+2**15+2**13+2**12 , 7  => 2**16+2**15+2**13  ,
          8  => 2**16+2**15+2**13                   , 9  => 2**16+2**15+2**12             , 10 => 2**16+2**15             , 11 => 2**16+2**15             , 12 => 2**16+2**14+2**13+2**12 , 13 => 2**16+2**14+2**13+2**11 , 14 => 2**16+2**14+2**13       , 15 => 2**16+2**14+2**13  ,
          16 => 2**16+2**14+2**12                   , 17 => 2**16+2**14+2**11             , 18 => 2**16+2**14+2**11       , 19 => 2**16+2**14             , 20 => 2**16+2**14             , 21 => 2**16+2**13 +2**12      , 22 => 2**16+2**13 +2**12      , 23 => 2**16+2**13 +2**12 ,
          24 => 2**16+2**13                         , 25 => 2**16+2**13                   , 26 => 2**16+2**13             , 27 => 2**16+2**12             , 28 => 2**16+2**12             , 29 => 2**16+2**11             , 30 => 2**16+2**10             , 31 => 2**16);
    begin
        return divisor_lut(get_lut_index(divisor));
    end get_initial_value_for_division;
--------------------------------------------------
------------------------------------------------------------------------
    procedure create_division
    (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record
    ) is
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
        alias division_process_counter is division.division_process_counter;
        alias res is division.res;
        alias res2 is division.res2;
        alias x is division.x;
        alias number_to_be_reciprocated is division.number_to_be_reciprocated; 
    begin
        
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
    end create_division;

------------------------------------------------------------------------

end package body division_pkg;
