library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.gate_drive_power_pkg.all;
    use work.gate_drive_power_internal_pkg.all;

entity gate_drive_power is
    port (
        gate_drive_power_clocks   : in gate_drive_power_clock_group;
        gate_drive_power_FPGA_out : out gate_drive_power_FPGA_output_group;
        gate_drive_power_data_in  : in gate_drive_power_data_input_group;
        gate_drive_power_data_out : out gate_drive_power_data_output_group
    );
end entity gate_drive_power;

architecture rtl of gate_drive_power is

    alias clock is gate_drive_power_clocks.clock;
    alias reset_n is gate_drive_power_clocks.reset_n;

    signal pwm_counter : natural range 0 to 2**12-1 := 0;
    constant pwm_max_value_for_200kHz_pwm : natural := 120e6/200e3;
    constant duty_ratio_for_30_percent_pwm : natural := 120e6/200e3/3;

begin 

------------------------------------------------------------------------
    gate_drive_power_controller : process(clock)
        
    begin
        if rising_edge(clock) then
            if reset_n = '0' then
            -- reset state
    
            else 

                if gate_drive_powers_are_turned_off(gate_drive_power_data_in) then
                    force_all_gate_drivers_off(gate_drive_power_FPGA_out);
                end if;
    
            end if; -- rstn
        end if; --rising_edge
    end process gate_drive_power_controller;	

------------------------------------------------------------------------
end rtl;
