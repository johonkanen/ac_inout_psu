package body system_control_internal_pkg is

------------------------------------------------------------------------
    procedure start_gate_drive_powers
    (
        signal system_components_input : out system_components_data_input_group
    ) is
        use work.gate_drive_power_pkg.all;
        alias gate_drive_power_input is system_components_input.power_supply_control_data_in.gate_drive_power_data_in;
    begin 
        start_gate_drive_powers(gate_drive_power_input);
    end start_gate_drive_powers;

------------------------------------------------------------------------
    procedure stop_gate_drive_powers
    (
        signal system_components_input : out system_components_data_input_group
    ) is
        use work.gate_drive_power_pkg.all;
        alias gate_drive_power_input is system_components_input.power_supply_control_data_in.gate_drive_power_data_in;
    begin 
        stop_gate_drive_powers(gate_drive_power_input);
    end stop_gate_drive_powers;

------------------------------------------------------------------------
    procedure idle_system
    (
        st_system_controller : out t_system_controller;
        signal system_component_input : out system_components_data_input_group;
        system_component_output : in system_components_data_output_group 
    ) is
    begin 
        st_system_controller := idle;
        stop_gate_drive_powers(system_component_input);
        
    end idle_system;
        
------------------------------------------------------------------------
end package body system_control_internal_pkg; 
