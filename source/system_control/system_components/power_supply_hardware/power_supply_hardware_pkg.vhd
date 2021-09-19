library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.power_supply_control_pkg.all;
    use work.gate_drive_power_pkg.all;
    use work.system_clocks_pkg.all;

package power_supply_hardware_pkg is

    type power_supply_hardware_FPGA_input_group is record
        power_supply_control_FPGA_in : power_supply_control_FPGA_input_group;
    end record;
    
    type power_supply_hardware_FPGA_output_group is record
        power_supply_control_FPGA_out : power_supply_control_FPGA_output_group; 
    end record;
    
    type power_supply_hardware_data_input_group is record
        power_supply_control_data_in : power_supply_control_data_input_group;
    end record;
    
    type power_supply_hardware_data_output_group is record
        power_supply_control_data_out : power_supply_control_data_output_group;
    end record;
    
    component power_supply_hardware is
        port (
            system_clocks                 : in system_clocks_group;
            power_supply_hardware_FPGA_in  : in power_supply_hardware_FPGA_input_group   ;
            power_supply_hardware_FPGA_out : out power_supply_hardware_FPGA_output_group ;
            power_supply_hardware_data_in  : in power_supply_hardware_data_input_group   ;
            power_supply_hardware_data_out : out power_supply_hardware_data_output_group
        );
    end component power_supply_hardware;

------------------------------------------------------------------------
    function gate_drivers_are_charged ( power_supply_hardware_out : power_supply_hardware_data_output_group)
        return boolean;
------------------------------------------------------------------------
    
    -- signal power_supply_hardware_clocks   : power_supply_hardware_clock_group;
    -- signal power_supply_hardware_FPGA_in  : power_supply_hardware_FPGA_input_group;
    -- signal power_supply_hardware_FPGA_out : power_supply_hardware_FPGA_output_group;
    -- signal power_supply_hardware_data_in  : power_supply_hardware_data_input_group;
    -- signal power_supply_hardware_data_out : power_supply_hardware_data_output_group
    
    -- u_power_supply_hardware : power_supply_hardware
    -- port map( power_supply_hardware_clocks,
    -- 	  power_supply_hardware_FPGA_in,
    --	  power_supply_hardware_FPGA_out,
    --	  power_supply_hardware_data_in,
    --	  power_supply_hardware_data_out);

    

------------------------------------------------------------------------
end package power_supply_hardware_pkg;


package body power_supply_hardware_pkg is

------------------------------------------------------------------------
    function gate_drivers_are_charged
    (
        power_supply_hardware_out : power_supply_hardware_data_output_group
    )
    return boolean
    is
    begin
        return true;
    end gate_drivers_are_charged;

------------------------------------------------------------------------
end package body power_supply_hardware_pkg;
