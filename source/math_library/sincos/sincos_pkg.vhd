library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 

library math_library;
    use math_library.multiplier_pkg.all;

package sincos_pkg is

------------------------------------------------------------------------
    function angle_reduction ( angle_in_rad16 : int18)
        return int18;
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
        angle_in_rad16 : int18
    )
        return int18
    is
        variable sign16_angle : signed(17 downto 0);
    begin
        sign16_angle := to_signed(angle_in_rad16,18); 
        return to_integer((sign16_angle(13 downto 0)));
    end angle_reduction;

------------------------------------------------------------------------ 
end package body sincos_pkg; 
