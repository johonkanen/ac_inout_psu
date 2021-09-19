-- library ieee;
--     use ieee.std_logic_1164.all;
--     use ieee.numeric_std.all;
--
-- library work;
--     use work.power_supply_hardware_pkg.all;
--     use work.system_clocks_pkg.all;
--
-- entity power_supply_hardware is
--     port (
--         system_clocks                  : in system_clocks_group                      ;
--         power_supply_hardware_FPGA_in  : in power_supply_hardware_FPGA_input_group   ;
--         power_supply_hardware_FPGA_out : out power_supply_hardware_FPGA_output_group ;
--         power_supply_hardware_data_in  : in power_supply_hardware_data_input_group   ;
--         power_supply_hardware_data_out : out power_supply_hardware_data_output_group
--     );
-- end entity power_supply_hardware;

architecture simulated_power_supply_hardware of power_supply_hardware is

    use work.power_supply_control_pkg.all; 
    signal power_supply_control_FPGA_in  : power_supply_control_FPGA_input_group;
    signal power_supply_control_FPGA_out : power_supply_control_FPGA_output_group;
    signal power_supply_control_data_in  : power_supply_control_data_input_group;
    signal power_supply_control_data_out : power_supply_control_data_output_group;

begin

------------------------------------------------------------------------ 
    power_supply_hardware_FPGA_out <= (
                                          power_supply_control_FPGA_out => power_supply_control_FPGA_out
                                      );

                                     

------------------------------------------------------------------------ 
------------------------------------------------------------------------ 
    power_supply_control_data_in <= (
                                      gate_drive_power_data_in =>  power_supply_hardware_data_in.power_supply_control_data_in.gate_drive_power_data_in
                                    );

    u_power_supply_control : power_supply_control
    port map( system_clocks                 ,
              power_supply_control_FPGA_in  ,
              power_supply_control_FPGA_out ,
              power_supply_control_data_in  ,
              power_supply_control_data_out); 
------------------------------------------------------------------------ 
end simulated_power_supply_hardware; 
