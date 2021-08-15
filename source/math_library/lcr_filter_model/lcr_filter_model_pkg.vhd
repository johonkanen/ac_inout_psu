library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.state_variable_pkg.all;

package lcr_filter_model_pkg is

------------------------------------------------------------------------
    type lcr_model_record is record
        inductor_current  : state_variable_record;
        capacitor_voltage : state_variable_record;
        process_counter   : natural range 0 to 7;

        inductor_current_delta     : int18;
        inductor_integrator_gain   : int18;
        capacitor_delta            : int18;
        capacitor_integrator_gain  : int18;
        load_resistance            : int18;
        inductor_series_resistance : int18;
    end record;

    constant init_lcr_filter : lcr_model_record := 
            (inductor_current          => (0, 0) ,
            capacitor_voltage          => (0, 0) ,
            process_counter            => 4      ,
            inductor_current_delta     => 0      ,
            inductor_integrator_gain   => 25e3   ,
            capacitor_integrator_gain  => 2000   ,
            load_resistance            => 10     ,
            capacitor_delta            => 10     ,
            inductor_series_resistance => 950);

------------------------------------------------------------------------
    procedure create_lcr_filter (
        signal lcr_filter : inout lcr_model_record;
        signal multiplier : inout multiplier_record;
        load_resistance   : int18;
        load_current      : int18;
        inductor_current_state_equation : int18;
        capacitor_voltage_state_equation : int18 );
------------------------------------------------------------------------
    procedure calculate_lcr_filter (
        signal lcr_filter : inout lcr_model_record);
------------------------------------------------------------------------
    function init_lcr_model_integrator_gains (
        inductor_integrator_gain : int18;
        capacitor_integrator_gain : int18)
        return lcr_model_record;

------------------------------------------------------------------------
end package lcr_filter_model_pkg;


package body lcr_filter_model_pkg is

------------------------------------------------------------------------
    procedure create_lcr_filter
    (
        signal lcr_filter : inout lcr_model_record;
        signal multiplier : inout multiplier_record;
        load_resistance   : int18;
        load_current      : int18;
        inductor_current_state_equation : int18;
        capacitor_voltage_state_equation : int18

    ) is
        alias hw_multiplier is multiplier;
        alias process_counter is lcr_filter.process_counter;
        alias inductor_current_delta is lcr_filter.inductor_current_delta;
        alias inductor_series_resistance is lcr_filter.inductor_series_resistance;
        alias inductor_current is lcr_filter.inductor_current;
        alias capacitor_voltage is lcr_filter.capacitor_voltage;
        alias capacitor_delta is lcr_filter.capacitor_delta;
    --------------------------------------------------
        impure function "*" ( left, right : int18)
        return int18
        is
        begin
            sequential_multiply(hw_multiplier, left, right);
            return get_multiplier_result(hw_multiplier, 15);
        end "*";
    --------------------------------------------------
    begin
            CASE process_counter is 
                WHEN 0 => 
                    inductor_current_delta <= inductor_series_resistance * inductor_current.state; 
                    increment_counter_when_ready(hw_multiplier, process_counter);

                WHEN 1 => 
                    integrate_state(inductor_current, hw_multiplier, 15, inductor_current_state_equation); -- input_voltage - capacitor_voltage.state - inductor_current_delta);
                    increment_counter_when_ready(hw_multiplier, process_counter);

                WHEN 2 => 
                    capacitor_delta <= load_resistance * capacitor_voltage.state;
                    increment_counter_when_ready(hw_multiplier, process_counter);

                WHEN 3 =>
                    integrate_state(capacitor_voltage, hw_multiplier, 15, capacitor_voltage_state_equation); -- inductor_current.state - load_current - capacitor_delta);
                    increment_counter_when_ready(hw_multiplier, process_counter);
                WHEN others => -- do nothing

            end CASE; 
    end create_lcr_filter;

------------------------------------------------------------------------
    procedure calculate_lcr_filter
    (
        signal lcr_filter : inout lcr_model_record
    ) is
    begin
        lcr_filter.process_counter <= 0; 
    end calculate_lcr_filter;

------------------------------------------------------------------------
    function init_lcr_model_integrator_gains
    (
        inductor_integrator_gain : int18;
        capacitor_integrator_gain : int18
    )
    return lcr_model_record
    is
        variable lcr_filter_init : lcr_model_record := init_lcr_filter;
    begin

        lcr_filter_init.inductor_current := init_state_variable_gain(inductor_integrator_gain);
        lcr_filter_init.capacitor_voltage := init_state_variable_gain(capacitor_integrator_gain);
        return lcr_filter_init;
        
    end init_lcr_model_integrator_gains;


------------------------------------------------------------------------
end package body lcr_filter_model_pkg; 
