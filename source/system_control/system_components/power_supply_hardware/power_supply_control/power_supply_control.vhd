library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.power_supply_control_pkg.all;
    use work.gate_drive_power_pkg.all;
    use work.system_clocks_pkg.all;

entity power_supply_control is
    port (
        system_clocks                 : in system_clocks_group;
        power_supply_control_FPGA_in  : in power_supply_control_FPGA_input_group;
        power_supply_control_FPGA_out : out power_supply_control_FPGA_output_group;
        power_supply_control_data_in  : in power_supply_control_data_input_group;
        power_supply_control_data_out : out power_supply_control_data_output_group
    );
end entity power_supply_control;

architecture rtl of power_supply_control is


    signal gate_drive_power_clocks   : gate_drive_power_clock_group;
    
begin 

    -- gate_drive_power_clocks <= (clock  => power_supply_control_clocks.clock,
    --                            reset_n => power_supply_control_clocks.reset_n);
------------------------------------------------------------------------
    u_gate_drive_power : gate_drive_power
    port map( gate_drive_power_clocks,
    	  power_supply_control_FPGA_out.gate_drive_power_FPGA_out,
    	  power_supply_control_data_in.gate_drive_power_data_in,
    	  power_supply_control_data_out.gate_drive_power_data_out);

------------------------------------------------------------------------
end rtl;
