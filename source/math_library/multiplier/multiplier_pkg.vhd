library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package multiplier_pkg is

    subtype signed_36_bit is signed(35 downto 0);
    subtype int18 is integer range -2**17 to 2**17-1;

    type multiplier_clock_group is record
        clock : std_logic;
    end record;
    
    type multiplier_data_input_group is record
        multiply_is_requested : boolean;
        input_1 : integer;
        input_2 : integer;
    end record;
    
    type multiplier_data_output_group is record
        multiplier_raw_result : signed_36_bit;
        multiplier_is_ready_when_1 : std_logic;
        multiplier_is_busy : boolean;
    end record;
    
    component multiplier is
        port (
            multiplier_clocks : in multiplier_clock_group; 
            multiplier_data_in : in multiplier_data_input_group;
            multiplier_data_out : out multiplier_data_output_group
        );
    end component multiplier;
    
    -- signal multiplier_clocks   : multiplier_clock_group;
    -- signal multiplier_data_in  : multiplier_data_input_group;
    -- signal multiplier_data_out : multiplier_data_output_group
    
    -- u_multiplier : multiplier
    -- port map( multiplier_clocks,
    --	  multiplier_data_in,
    --	  multiplier_data_out); 
    
------------------------------------------------------------------------
    procedure init_multiplier (
        signal multiplier_input : out multiplier_data_input_group);
------------------------------------------------------------------------
    procedure request_multiply (
        signal multiplier_input : out multiplier_data_input_group);
------------------------------------------------------------------------
    procedure multiply (
        signal multiplier_input : out multiplier_data_input_group;
        data_a : in int18;
        data_b : in int18);
------------------------------------------------------------------------
    procedure multiply (
        signal multiplier_input : out multiplier_data_input_group;
        multiplier_output : in multiplier_data_output_group;
        data_a : in int18;
        data_b : in int18);
------------------------------------------------------------------------
    function get_multiplier_result (
        multiplier_output : multiplier_data_output_group;
        radix : natural range 0 to 18) 
    return integer ;
------------------------------------------------------------------------
    function multiplier_is_ready (
        multiplier_output : multiplier_data_output_group)
    return boolean;
------------------------------------------------------------------------
    function multiplier_is_not_busy (
        multiplier_output : multiplier_data_output_group)
        return boolean;

end package multiplier_pkg;

package body multiplier_pkg is

------------------------------------------------------------------------
    procedure init_multiplier
    (
        signal multiplier_input : out multiplier_data_input_group
    ) is
    begin
        multiplier_input.multiply_is_requested <= false;
    end init_multiplier;

------------------------------------------------------------------------
    procedure request_multiply
    (
        signal multiplier_input : out multiplier_data_input_group
    ) is
    begin
        multiplier_input.multiply_is_requested <= true;
    end request_multiply;

------------------------------------------------------------------------
    procedure multiply
    (
        signal multiplier_input : out multiplier_data_input_group;
        data_a : in int18;
        data_b : in int18
    ) is
    begin
        multiplier_input.input_1 <= data_a;
        multiplier_input.input_2 <= data_b; 
        request_multiply(multiplier_input);
        
    end multiply;
------------------------------------------------------------------------
    procedure multiply -- blocking multiply
    (
        signal multiplier_input : out multiplier_data_input_group;
        multiplier_output : in multiplier_data_output_group;
        data_a : in int18;
        data_b : in int18
    ) is
    begin
        multiplier_input.input_1 <= data_a;
        multiplier_input.input_2 <= data_b; 
        multiplier_input.multiply_is_requested <= false;
        if not multiplier_output.multiplier_is_busy then
            request_multiply(multiplier_input);
        end if;
        
    end multiply;

------------------------------------------------------------------------
    function multiplier_is_ready
    (
        multiplier_output : multiplier_data_output_group
    )
    return boolean
    is
    begin
        if multiplier_output.multiplier_is_ready_when_1 = '1' then
            return true;
        else
            return false;
        end if;
    end multiplier_is_ready;

------------------------------------------------------------------------
    -- get rounded result
    function get_multiplier_result
    (
        multiplier_output : multiplier_data_output_group;
        radix : natural range 0 to 18
    ) return integer 
    is
    ---------------------------------------------------
        function "+"
        (
            left : integer;
            right : std_logic 
        )
        return integer
        is
        begin
            if left > 0 then
                if right = '1' then
                    return left + 1;
                else
                    return left;
                end if;
            else
                return left;
            end if;
        end "+";
    --------------------------------------------------         
        variable bit_vector_slice : signed(17 downto 0);
        constant output_word_bit_width : natural := 18;
        alias multiplier_raw_result is multiplier_output.multiplier_raw_result;
    begin
        bit_vector_slice := multiplier_output.multiplier_raw_result((multiplier_raw_result'left-output_word_bit_width + radix) downto radix); 
        if radix > 0 then
            return to_integer(bit_vector_slice) + multiplier_raw_result(radix - 1);
        else
            return to_integer(bit_vector_slice);
        end if;
        
    end get_multiplier_result;

------------------------------------------------------------------------ 
    function multiplier_is_not_busy
    (
        multiplier_output : multiplier_data_output_group
    )
    return boolean
    is
    begin
        return not multiplier_output.multiplier_is_busy;
    end multiplier_is_not_busy;


------------------------------------------------------------------------
end package body multiplier_pkg; 