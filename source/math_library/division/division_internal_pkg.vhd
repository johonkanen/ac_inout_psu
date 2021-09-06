library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

package division_internal_pkg is
    function remove_leading_zeros ( number : int18)
        return int18;

    function get_initial_value_for_division ( divisor : natural)
        return natural;

    function invert_bits ( number : natural)
        return natural;

end package division_internal_pkg;


package body division_internal_pkg is

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
    function remove_leading_zeros
    (
        number : int18
    )
    return int18
    is
        variable uint_18 : unsigned(17 downto 0);
        variable uint_17 : unsigned(16 downto 0);

    begin
        -- TODO, fix this currently does not work for number > 65536
        uint_18 := to_unsigned(abs(number),18);
        if uint_18(16) = '1' then
            uint_17 := uint_18(17 downto 1);
        else
            uint_17 := uint_18(16 downto 0);
        end if;


        if to_integer(uint_17(15 downto 15- 15)) = 0 then
            return number * 2**(16-(    15- 15));
        end if;

        if to_integer(uint_17(15 downto 15- 14)) = 0 then
            return number * 2**(16-(    15- 14));
        end if;

        if to_integer(uint_17(15 downto 15- 13)) = 0 then
            return number * 2**(16-(    15- 13));
        end if;

        if to_integer(uint_17(15 downto 15- 12)) = 0 then
            return number * 2**(16-(    15- 12));
        end if;

        if to_integer(uint_17(15 downto 15- 11)) = 0 then
            return number * 2**(16-(    15- 11));
        end if;

        if to_integer(uint_17(15 downto 15- 10)) = 0 then
            return number * 2**(16-(    15- 10));
        end if;

        if to_integer(uint_17(15 downto 15- 9)) = 0 then
            return number * 2**(16-(    15- 9));
        end if;

        if to_integer(uint_17(15 downto 15- 8)) = 0 then
            return number * 2**(16-(    15- 8));
        end if;

        if to_integer(uint_17(15 downto 15- 7)) = 0 then
           return number * 2**(16-(     15- 7));
        end if;

        if to_integer(uint_17(15 downto 15- 6)) = 0 then
            return number * 2**(16-(    15- 6));
        end if; 

        if to_integer(uint_17(15 downto 15- 5)) = 0 then
            return number * 2**(16-(    15- 5));
        end if;

        if to_integer(uint_17(15 downto 15- 4)) = 0 then
            return number * 2**(16-(    15- 4));
        end if;

        if to_integer(uint_17(15 downto 15- 3)) = 0 then
            return number * 2**(16-(    15- 3));
        end if; 

        if to_integer(uint_17(15 downto 15- 2)) = 0 then
            return number * 2**(16-(    15- 2));
        end if;

        if to_integer(uint_17(15 downto 15- 1)) = 0 then
            return number * 2**(16-(    15- 1));
        end if;

        if to_integer(uint_17(15 downto 15- 0)) = 0 then
            return number * 2**(16-(    15- 0));
        end if;

        return number;
        
    end remove_leading_zeros; 

end package body division_internal_pkg;

