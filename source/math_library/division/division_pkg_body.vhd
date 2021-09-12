package body division_pkg is

------------------------------------------------------------------------
    procedure create_division
    (
        signal hw_multiplier : inout multiplier_record;
        signal division : inout division_record
    ) is
    --------------------------------------------------
        alias division_process_counter is division.division_process_counter;
        alias x is division.x;
        alias number_to_be_reciprocated is division.number_to_be_reciprocated; 
        alias number_of_newton_raphson_iteration is division.number_of_newton_raphson_iteration; 
        alias dividend is division.dividend;
        variable xa : int18;
    --------------------------------------------------
    begin
        
        CASE division_process_counter is
            WHEN 0 =>
                multiply(hw_multiplier, number_to_be_reciprocated, x);
                division_process_counter <= division_process_counter + 1;
            WHEN 1 =>
                if multiplier_is_ready(hw_multiplier) then
                    xa := get_multiplier_result(hw_multiplier, 16);
                    multiply(hw_multiplier, x, invert_bits(xa));
                end if;
                increment_counter_when_ready(hw_multiplier,division_process_counter);
            WHEN 2 =>
                if multiplier_is_ready(hw_multiplier) then
                    x <= get_multiplier_result(hw_multiplier, 16);
                    if number_of_newton_raphson_iteration /= 0 then
                        number_of_newton_raphson_iteration <= number_of_newton_raphson_iteration - 1;
                        division_process_counter <= 0;
                    else
                        division_process_counter <= division_process_counter + 1;
                        multiply(hw_multiplier, get_multiplier_result(hw_multiplier, 16), dividend);
                    end if;
                end if;
            WHEN others => -- wait for start
        end CASE;
    end create_division;

------------------------------------------------------------------------
    procedure request_division
    (
        signal division : out division_record;
        number_to_be_divided : int18;
        number_to_be_reciprocated : int18
    ) is
        variable abs_number_to_be_reciprocated : natural range 0 to 2**17-1;
    begin
        abs_number_to_be_reciprocated := abs(number_to_be_reciprocated);
        division.divisor <= abs_number_to_be_reciprocated;
        division.division_process_counter  <= 0;
        division.x                         <= get_initial_value_for_division(remove_leading_zeros(abs_number_to_be_reciprocated));
        division.number_to_be_reciprocated <= remove_leading_zeros(abs_number_to_be_reciprocated);
        division.dividend                  <= number_to_be_divided;
    end request_division;

------------------------------------------------------------------------
    procedure request_division
    (
        signal division : out division_record;
        number_to_be_divided : int18;
        number_to_be_reciprocated : int18;
        iterations : in natural range 1 to 2
    ) is
    begin
        request_division(division, number_to_be_divided, number_to_be_reciprocated);
        division.number_of_newton_raphson_iteration <= iterations - 1;
    end request_division;


------------------------------------------------------------------------
    function division_is_ready
    (
        division_multiplier : multiplier_record;
        division : division_record
    )
    return boolean
    is
    begin
        if division.division_process_counter = 3 then
            return multiplier_is_ready(division_multiplier);
        else
            return false;
        end if;
        
    end division_is_ready;
------------------------------------------------------------------------ 

    function division_is_busy
    (
        division : in division_record
    )
    return boolean
    is
    begin
        return division.division_process_counter /= 3;
    end division_is_busy;

------------------------------------------------------------------------
    function get_division_result
    (
        multiplier : multiplier_record;
        hw_divider : division_record;
        radix : natural
    )
    return natural
    is
        variable multiplier_result : integer;
    begin
            multiplier_result := get_multiplier_result(multiplier,radix);
            if hw_divider.divisor < 2**1  then return (multiplier_result)*2**15; end if;
            if hw_divider.divisor < 2**2  then return (multiplier_result)*2**14; end if;
            if hw_divider.divisor < 2**3  then return (multiplier_result)*2**13; end if;
            if hw_divider.divisor < 2**4  then return (multiplier_result)*2**12; end if;
            if hw_divider.divisor < 2**5  then return (multiplier_result)*2**11; end if;
            if hw_divider.divisor < 2**6  then return (multiplier_result)*2**10; end if;
            if hw_divider.divisor < 2**7  then return (multiplier_result)*2**9; end if;
            if hw_divider.divisor < 2**8  then return (multiplier_result)*2**8; end if;
            if hw_divider.divisor < 2**9  then return (multiplier_result)*2**7; end if;
            if hw_divider.divisor < 2**10 then return (multiplier_result)*2**6; end if;
            if hw_divider.divisor < 2**11 then return (multiplier_result)*2**5; end if;
            if hw_divider.divisor < 2**12 then return (multiplier_result)*2**4; end if;
            if hw_divider.divisor < 2**13 then return (multiplier_result)*2**3; end if;
            if hw_divider.divisor < 2**14 then return (multiplier_result)*2**2; end if;
            if hw_divider.divisor < 2**15 then return (multiplier_result)*2**1; end if;
            if hw_divider.divisor < 2**16 then return (multiplier_result)/2**0; end if;

            return (multiplier_result)/2**1;
        
    end get_division_result;

------------------------------------------------------------------------ 
end package body division_pkg;
