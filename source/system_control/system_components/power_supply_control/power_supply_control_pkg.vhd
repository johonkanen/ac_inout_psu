library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.gate_drive_power_pkg.all;

package power_supply_control_pkg is

    type power_supply_control_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type power_supply_control_FPGA_input_group is record
        clock : std_logic;
    end record;
    
    type power_supply_control_FPGA_output_group is record
        clock : std_logic;
        gate_drive_power_FPGA_out : gate_drive_power_FPGA_output_group;
    end record;
    
    type power_supply_control_data_input_group is record
        gate_drive_power_data_in  : gate_drive_power_data_input_group;
    end record;
    
    type power_supply_control_data_output_group is record
        gate_drive_power_data_out : gate_drive_power_data_output_group;
    end record;
    
    component power_supply_control is
        port (
            power_supply_control_clocks : in power_supply_control_clock_group; 
            power_supply_control_FPGA_in : in power_supply_control_FPGA_input_group;
            power_supply_control_FPGA_out : out power_supply_control_FPGA_output_group; 
            power_supply_control_data_in : in power_supply_control_data_input_group;
            power_supply_control_data_out : out power_supply_control_data_output_group
        );
    end component power_supply_control;
    
    -- signal power_supply_control_clocks   : power_supply_control_clock_group;
    -- signal power_supply_control_FPGA_in  : power_supply_control_FPGA_input_group;
    -- signal power_supply_control_FPGA_out : power_supply_control_FPGA_output_group;
    -- signal power_supply_control_data_in  : power_supply_control_data_input_group;
    -- signal power_supply_control_data_out : power_supply_control_data_output_group
    
    -- u_power_supply_control : power_supply_control
    -- port map( power_supply_control_clocks,
    -- 	  power_supply_control_FPGA_in,
    --	  power_supply_control_FPGA_out,
    --	  power_supply_control_data_in,
    --	  power_supply_control_data_out);
    

end package power_supply_control_pkg;
