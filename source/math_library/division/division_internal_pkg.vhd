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
        type divisor_lut_array is array (integer range 0 to 31) of natural;
        constant divisor_lut : divisor_lut_array := ( 
          0  => 63 ,
          1  => 61 ,
          2  => 59 ,
          3  => 57 ,
          4  => 56 ,
          5  => 54 ,
          6  => 53 ,
          7  => 52 ,
          8  => 50 ,
          9  => 49 ,
          10 => 48 ,
          11 => 47 ,
          12 => 46 ,
          13 => 45 ,
          14 => 44 ,
          15 => 43 , -- last
          16 => 42 ,
          17 => 41 , -- *
          18 => 40 ,
          19 => 39 ,
          20 => 39 ,
          21 => 38 ,
          22 => 37 ,
          23 => 37 ,
          24 => 36 ,
          25 => 36 ,
          26 => 35 ,
          27 => 34 ,
          28 => 34 ,
          29 => 33 ,
          30 => 32 ,
          31 => 32);
    begin
        return divisor_lut(get_lut_index(divisor))*2**11;
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

