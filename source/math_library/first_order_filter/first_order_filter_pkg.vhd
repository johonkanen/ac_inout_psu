library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;

package first_order_filter_pkg is

------------------------------------------------------------------------

------------------------------------------------------------------------
    type first_order_filter is record
        process_counter : natural range 0 to 15;
        filter_is_ready : boolean;
        filter_is_busy : boolean;
        filter_input : int18;
        filter_output : int18;
        filter_memory : int18; 
    end record;

    constant init_filter_state : first_order_filter := (process_counter => 9, filter_is_ready => false, filter_is_busy => false, filter_input => 0, filter_output => 0, filter_memory => 0); 

--------------------------------------------------
    procedure create_first_order_filter (
        signal filter : inout first_order_filter;
        signal multiplier_in : out multiplier_data_input_group;
        multiplier_out :  in multiplier_data_output_group;
        constant b0 : int18;
        constant b1 : int18);
--------------------------------------------------
    procedure filter_data (
        signal filter : out first_order_filter;
        data_to_filter : in int18);
--------------------------------------------------
    function get_filter_output ( filter : in first_order_filter)
        return int18;


end package first_order_filter_pkg;


package body first_order_filter_pkg is
------------------------------------------------------------------------
    procedure create_first_order_filter
    (
        signal filter : inout first_order_filter;
        signal multiplier_in : out multiplier_data_input_group;
        multiplier_out :  in multiplier_data_output_group;
        constant b0 : int18;
        constant b1 : int18
    ) is
        constant a1 : int18 := 2**17-1-b1-b0;
    begin
            CASE filter.process_counter is
                WHEN 0 =>
                    multiply(multiplier_in, filter.filter_input, b0);
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 1 =>
                    multiply(multiplier_in, filter.filter_input, b1);
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 2 =>
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 3 =>
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 4 =>
                    filter.filter_output <= filter.filter_memory + get_multiplier_result(multiplier_out, 17);
                    multiply(multiplier_in, filter.filter_output, a1);
                    filter.process_counter <= filter.process_counter + 1;
                    
                WHEN 5 =>
                    filter.filter_memory <= get_multiplier_result(multiplier_out, 17);
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 6 =>
                    filter.process_counter <= filter.process_counter + 1;

                WHEN 7 =>
                    filter.process_counter <= filter.process_counter + 1;

                when 8 =>
                    filter.filter_memory <= filter.filter_memory + get_multiplier_result(multiplier_out, 17);
                    filter.process_counter <= filter.process_counter + 1;

                WHEN others => -- do nothing
            end CASE; 
        
    end create_first_order_filter;
------------------------------------------------------------------------ 

    procedure filter_data
    (
        signal filter : out first_order_filter;
        data_to_filter : in int18
    ) is
    begin
        filter.process_counter <= 0;
        filter.filter_input <= data_to_filter;
        
    end filter_data;

    function get_filter_output
    (
        filter : in first_order_filter
    )
    return int18
    is
    begin
        return filter.filter_output;
    end get_filter_output;
------------------------------------------------------------------------



end package body first_order_filter_pkg;

