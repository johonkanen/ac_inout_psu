library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

entity multiplier is
    port (
        multiplier_clocks : in multiplier_clock_group; 
        multiplier_data_in : in multiplier_data_input_group;
        multiplier_data_out : out multiplier_data_output_group
    );
end entity;

architecture rtl of multiplier is

    alias clock is multiplier_clocks.clock; 
    alias multiply_is_requested is multiplier_data_in.multiply_is_requested;

    type int18_array is array (integer range <>) of int18;

    procedure shift_and_register
    (
        signal shift_register : inout int18_array;
        data_in : int18 
    ) is
    begin
        shift_register(shift_register(1) to shift_register'high) <= shift_register(shift_register(0) to shift_register'high-1);
        shift_register(0) <= data_in; 

    end shift_and_register;

    signal signed_data_a : signed(17 downto 0);
    signal signed_data_b : signed(17 downto 0);
    signal signed_36_bit_result : signed(35 downto 0);

    signal shift_register : std_logic_vector(2 downto 0);
    
    function boolean_to_std_logic
    (
        input_is_true : boolean
    )
    return std_logic
    is
    begin
        if input_is_true then
            return '1';
        else
            return '0';
        end if;
        
    end boolean_to_std_logic;

    function std_logic_to_boolean
    (
        bit_to_be_converted : std_logic 
    
    )
    return boolean
    is
    begin
        if bit_to_be_converted = '1' then
            return true;
        else
            return false;
        end if;
    end std_logic_to_boolean;

begin

    signed_18x18_multiplier : process(clock)
        
    begin
        if rising_edge(clock) then
            signed_data_a <= to_signed(multiplier_data_in.input_1, 18);
            signed_data_b <= to_signed(multiplier_data_in.input_2, 18);

            signed_36_bit_result <= signed_data_a * signed_data_b;

            multiplier_data_out.multiplier_raw_result <= signed_36_bit_result;

            shift_register <= shift_register(shift_register'left-1 downto 0) & boolean_to_std_logic(multiplier_data_in.multiply_is_requested); 
            multiplier_data_out.multiplier_is_busy <= false;
            if shift_register(shift_register'left) /= '0' then
                multiplier_data_out.multiplier_is_busy <= true;
            end if; 

        end if; --rising_edge
    end process signed_18x18_multiplier;	
    multiplier_data_out.multiplier_is_ready_when_1 <= shift_register(shift_register'left); 

end rtl;
