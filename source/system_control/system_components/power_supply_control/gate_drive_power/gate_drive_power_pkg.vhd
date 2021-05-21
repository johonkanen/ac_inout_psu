library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package gate_drive_power_pkg is

    type list_of_gate_drive_power_supplies_for is (grid_afe_leg1 , grid_afe_leg2 , psu_afe_leg1 , psu_afe_leg2 , dab_primary , dab_secondary);
    type gate_drive_pwm_output_array is array (list_of_gate_drive_power_supplies_for range list_of_gate_drive_power_supplies_for'left to list_of_gate_drive_power_supplies_for'right) of std_logic;

    type gate_drive_power_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type gate_drive_power_FPGA_output_group is record
        gate_drive_power_pwm_output : gate_drive_pwm_output_array; 
    end record;
    
    type gate_drive_power_data_input_group is record
        gate_driver_powers_are_started : boolean;
    end record;
    
    type gate_drive_power_data_output_group is record
        gate_driver_powers_are_ready : boolean;
    end record;
    
    component gate_drive_power is
        port (
            gate_drive_power_clocks   : in gate_drive_power_clock_group;
            gate_drive_power_FPGA_out : out gate_drive_power_FPGA_output_group;
            gate_drive_power_data_in  : in gate_drive_power_data_input_group;
            gate_drive_power_data_out : out gate_drive_power_data_output_group
        );
    end component gate_drive_power;
    
    -- signal gate_drive_power_clocks   : gate_drive_power_clock_group;
    -- signal gate_drive_power_FPGA_out : gate_drive_power_FPGA_output_group;
    -- signal gate_drive_power_data_in  : gate_drive_power_data_input_group;
    -- signal gate_drive_power_data_out : gate_drive_power_data_output_group
    
    -- u_gate_drive_power : gate_drive_power
    -- port map( gate_drive_power_clocks,
    --	  gate_drive_power_FPGA_out,
    --	  gate_drive_power_data_in,
    --	  gate_drive_power_data_out);
    
------------------------------------------------------------------------
    procedure init_gate_drive_power (
        signal gate_drive_power_input : out gate_drive_power_data_input_group);
------------------------------------------------------------------------
    procedure start_gate_drive_powers (
        signal gate_drive_power_input : out gate_drive_power_data_input_group);
------------------------------------------------------------------------
    procedure stop_gate_drive_powers (
        signal gate_drive_power_input : out gate_drive_power_data_input_group);
------------------------------------------------------------------------
    function gate_drive_powers_are_ready ( gate_drive_power_output : gate_drive_power_data_output_group)
        return boolean;

------------------------------------------------------------------------
end package gate_drive_power_pkg;

package body gate_drive_power_pkg is

------------------------------------------------------------------------
    procedure init_gate_drive_power
    (
        signal gate_drive_power_input : out gate_drive_power_data_input_group
    ) is
    begin
        gate_drive_power_input.gate_driver_powers_are_started <= false;
    end init_gate_drive_power;

------------------------------------------------------------------------
    procedure start_gate_drive_powers
    (
        signal gate_drive_power_input : out gate_drive_power_data_input_group
    ) is
    begin
        gate_drive_power_input.gate_driver_powers_are_started <= true; 
    end start_gate_drive_powers;

------------------------------------------------------------------------
    procedure stop_gate_drive_powers
    (
        signal gate_drive_power_input : out gate_drive_power_data_input_group
    ) is
    begin
        gate_drive_power_input.gate_driver_powers_are_started <= false; 
    end stop_gate_drive_powers;

------------------------------------------------------------------------
    function gate_drive_powers_are_ready
    (
        gate_drive_power_output : gate_drive_power_data_output_group
    )
    return boolean
    is
    begin
        return gate_drive_power_output.gate_driver_powers_are_ready;
    end gate_drive_powers_are_ready;

------------------------------------------------------------------------
end package body gate_drive_power_pkg; 
