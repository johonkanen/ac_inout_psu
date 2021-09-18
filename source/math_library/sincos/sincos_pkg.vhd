library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 

library math_library;
    use math_library.multiplier_pkg.all;

package sincos_pkg is

------------------------------------------------------------------------
    type sincos_record is record
        sincos_process_counter : natural               ;
        angle_rad16            : unsigned(15 downto 0) ;

        test_reduced_angle : integer;
        angle_squared : int18;
        sin16 : int18;
        cos16 : int18;
        sin : int18;
        cos : int18;
        sincos_is_ready : boolean;
    end record;

    constant init_sincos : sincos_record := (0, (others => '0'), 0, 0, 0, 0, 0, 0, false);
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
    procedure create_sincos
    (
        signal hw_multiplier : inout multiplier_record;
        signal sincos_object : inout sincos_record
    ) is
        alias sincos_process_counter is sincos_object.sincos_process_counter;
        alias angle_rad16            is sincos_object.angle_rad16           ;
        alias test_reduced_angle     is sincos_object.test_reduced_angle    ;
        alias angle_squared          is sincos_object.angle_squared         ;
        alias sin16                  is sincos_object.sin16                 ;
        alias cos16                  is sincos_object.cos16                 ;
        alias sin                    is sincos_object.sin                   ;
        alias cos                    is sincos_object.cos                   ;
        alias sincos_is_ready        is sincos_object.sincos_is_ready       ;
    begin
            sincos_is_ready <= false;
            CASE sincos_process_counter is
                WHEN 0 =>
                    test_reduced_angle <= (to_integer(angle_rad16));
                    multiply(hw_multiplier, angle_reduction(to_integer(angle_rad16)), angle_reduction(to_integer(angle_rad16)));
                    sincos_process_counter <= sincos_process_counter + 1;
                WHEN 1 =>
                    if multiplier_is_ready(hw_multiplier) then
                        angle_squared <=        get_multiplier_result(hw_multiplier, 15);
                        multiply(hw_multiplier,                sinegains(2), get_multiplier_result(hw_multiplier, 15));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 2 =>
                    if multiplier_is_ready(hw_multiplier) then 
                        multiply(hw_multiplier, angle_squared, sinegains(1) - get_multiplier_result(hw_multiplier, 15)); 
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 3 =>
                    if multiplier_is_ready(hw_multiplier) then
                        multiply(hw_multiplier, angle_reduction(test_reduced_angle), sinegains(0) - get_multiplier_result(hw_multiplier, 15)); 
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter);
                WHEN 4 =>
                    if multiplier_is_ready(hw_multiplier) then
                        sin16 <= get_multiplier_result(hw_multiplier,12);
                        multiply(hw_multiplier, angle_squared, cosgains(2));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 

                WHEN 5 =>
                    if multiplier_is_ready(hw_multiplier) then
                        multiply(hw_multiplier, angle_squared, cosgains(1) - get_multiplier_result(hw_multiplier, 15));
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 
                WHEN 6 => 
                    if multiplier_is_ready(hw_multiplier) then
                        cos16 <= cosgains(0) - get_multiplier_result(hw_multiplier, 14);
                    end if;
                    increment_counter_when_ready(hw_multiplier,sincos_process_counter); 
                WHEN 7 =>
                    sincos_process_counter <= sincos_process_counter + 1;
                    sincos_is_ready <= true;

                    if test_reduced_angle < one_quarter then
                        sin <= sin16;
                        cos <= cos16;
                    elsif test_reduced_angle < three_fourths then
                        sin <= cos16;
                        cos <= -sin16;
                    elsif test_reduced_angle < five_fourths then
                        sin <= -sin16;
                        cos <= -cos16;
                    elsif test_reduced_angle < seven_fourths then
                        sin <= -cos16;
                        cos <= sin16;
                    else
                        sin <= sin16;
                        cos <= cos16;
                    end if;

                when others => -- hange here and wait for triggering
            end CASE; 
        
    end create_sincos;

------------------------------------------------------------------------ 
end package body sincos_pkg; 
