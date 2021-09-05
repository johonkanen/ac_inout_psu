library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

package division_pkg is
--------------------------------------------------
    type division_record is record
        division_process_counter : natural range 0 to 3;
        x: int18;
        number_to_be_reciprocated : int18;
        number_of_newton_raphson_iteration : natural range 0 to 1;
        dividend : int18;
        divider_radix : natural range 0 to 17;
    end record;

    constant init_division : division_record := (3, 0, 0, 0, 0, 0);
------------------------------------------------------------------------
    procedure create_division (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record);

------------------------------------------------------------------------
    function get_initial_value_for_division ( divisor : natural)
        return natural;

------------------------------------------------------------------------
    function division_is_ready ( division_multiplier : multiplier_record; division : division_record)
        return boolean;

------------------------------------------------------------------------
    function remove_leading_zeros ( number : int18)
        return int18;

------------------------------------------------------------------------
    procedure request_division (
        signal division : out division_record;
        number_to_be_divided : int18;
        number_to_be_reciprocated : int18);
------------------------------------------------------------------------
    procedure request_division (
        signal division : out division_record;
        number_to_be_divided : int18;
        number_to_be_reciprocated : int18;
        iterations : in natural range 1 to 2);
------------------------------------------------------------------------
    function division_is_busy ( division : in division_record)
        return boolean;

------------------------------------------------------------------------
    function get_division_result ( division_result : int18)
        return natural;
------------------------------------------------------------------------
end package division_pkg;