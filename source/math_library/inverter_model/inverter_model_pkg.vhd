library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.state_variable_pkg.all;
    use math_library.lcr_filter_model_pkg.all;

package inverter_model_pkg is

    type inverter_model_record is record
        duty_ratio          : int18;
        dc_link_current     : int18;
        load_current        : int18;
        inverter_multiplier : multiplier_record;
        inverter_lc_filter  : lcr_model_record;
        dc_link_voltage     : state_variable_record;
        load_resistor_current : int18;
        input_voltage : int18;
        grid_inverter_state_counter : natural range 0 to 7;
    end record;

end package inverter_model_pkg;

package body inverter_model_pkg is

    procedure create_inverter_model
    (
        signal inverter_model : inout inverter_model_record;
        dc_link_load_current : in int18;
        load_current : in int18
    ) is
        alias inverter_multiplier is inverter_model.inverter_multiplier;
        alias dc_link_voltage is inverter_model.dc_link_voltage;
        alias dc_link_current is inverter_model.dc_link_current;
        alias inverter_lc_filter is inverter_model.inverter_lc_filter;
        alias input_voltage is inverter_model.input_voltage;
        alias grid_inverter_state_counter is inverter_model.grid_inverter_state_counter;
        alias duty_ratio is inverter_model.duty_ratio;

    begin
        create_multiplier(inverter_multiplier);
        create_state_variable(dc_link_voltage, inverter_multiplier, dc_link_current - dc_link_load_current); 
        create_lcr_filter(inverter_lc_filter, inverter_multiplier, input_voltage - inverter_lc_filter.capacitor_voltage, inverter_lc_filter.inductor_current.state - load_current);

        CASE grid_inverter_state_counter is
            WHEN 0 =>
                input_voltage <= 50e3 * duty_ratio;
                increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
            WHEN 1 =>
                dc_link_current <= inverter_lc_filter.inductor_current.state * duty_ratio;
                increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
            WHEN 2 =>
                calculate(dc_link_voltage);
                increment_counter_when_ready(inverter_multiplier, grid_inverter_state_counter);
            WHEN 3 =>
                calculate_lcr_filter(inverter_lc_filter);
                grid_inverter_state_counter <= grid_inverter_state_counter + 1;
            WHEN others => -- wait for restart
        end CASE;
        
    end create_inverter_model;

end package body inverter_model_pkg; 
