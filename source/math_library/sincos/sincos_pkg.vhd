library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 

library math_library;
    use math_library.multiplier_pkg.all;

package sincos_pkg is

------------------------------------------------------------------------
    function angle_reduction ( angle_in_rad16 : natural)
        return natural;
------------------------------------------------------------------------
    type int18_array is array (integer range <>) of int18;
    constant sinegains : int18_array(0 to 2) := (12868 , 21159 , 10180);
    constant cosgains  : int18_array(0 to 2) := (32768 , 80805 , 64473);

    constant one_quarter   : integer := 8192;
    constant three_fourths : integer := 24576;
    constant five_fourths  : integer := 40960;
    constant seven_fourths : integer := 57344;

end package sincos_pkg;


package body sincos_pkg is

------------------------------------------------------------------------
    function angle_reduction
    (
        angle_in_rad16 : natural
    )
    return natural
    is 
        variable unsigned_angle : unsigned(15 downto 0);
        variable reduced_angle : natural;
    begin
        unsigned_angle := to_unsigned(angle_in_rad16,16);
        reduced_angle := to_integer(unsigned_angle(12 downto 0)); 
        return reduced_angle;
    end angle_reduction;

------------------------------------------------------------------------ 
end package body sincos_pkg; 
