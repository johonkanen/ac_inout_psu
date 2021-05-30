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
        start_multiplier : boolean;
        input_1 : integer;
        input_2 : integer;
    end record;
    
    type multiplier_data_output_group is record
        multiplier_raw_result : signed_36_bit;
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
    

end package multiplier_pkg;

package body multiplier_pkg is

------------------------------------------------------------------------
    procedure init_multiplier
    (
        signal multiplier_input : out multiplier_data_input_group
    ) is
    begin
        multiplier_input.start_multiplier <= false;
    end init_multiplier;

------------------------------------------------------------------------
    procedure start_multiplier
    (
        signal multiplier_input : out multiplier_data_input_group
    ) is
    begin
        multiplier_input.start_multiplier <= true;
    end start_multiplier;

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
        start_multiplier(multiplier_input);
        
    end multiply;

------------------------------------------------------------------------
    function get_multiplier_result
    (
        multiplier_output : multiplier_data_output_group;
        radix : natural range 0 to 18
    ) return integer 
    is
        variable bit_vector_slice : signed(17 downto 0);
        constant output_word_bit_width : natural := 18;
        alias multiplier_raw_result is multiplier_output.multiplier_raw_result;
    begin
        bit_vector_slice := multiplier_output.multiplier_raw_result(multiplier_raw_result'left-radix downto output_word_bit_width - radix); 
        return to_integer(bit_vector_slice);
        
    end get_multiplier_result;

------------------------------------------------------------------------
end package body multiplier_pkg;

