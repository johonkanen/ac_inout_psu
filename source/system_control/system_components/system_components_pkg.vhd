library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;
    use work.ethernet_communication_pkg.all;
    

package system_components_pkg is

    type system_components_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type system_components_FPGA_input_group is record
        power_supply_control_FPGA_in   : power_supply_control_FPGA_input_group;
        uart_FPGA_in                   : uart_FPGA_input_group;
        spi_sar_adc_FPGA_in            : spi_sar_adc_FPGA_input_group;
        ethernet_communication_FPGA_in : ethernet_communication_FPGA_input_group;
    end record;
    
    type system_components_FPGA_output_group is record
        power_supply_control_FPGA_out   : power_supply_control_FPGA_output_group;
        uart_FPGA_out                   : uart_FPGA_output_group;
        spi_sar_adc_FPGA_out            : spi_sar_adc_FPGA_output_group;
        test_ad_mux                     : std_logic_vector(2 downto 0);
        ethernet_communication_FPGA_out : ethernet_communication_FPGA_output_group;
        led : std_logic;
    end record;

    type system_components_FPGA_inout_record is record
        ethernet_communication_FPGA_inout : ethernet_communication_FPGA_inout_record;
    end record;
    
    type system_components_data_input_group is record
        power_supply_control_data_in : power_supply_control_data_input_group;
    end record;
    
    type system_components_data_output_group is record
        power_supply_control_data_out : power_supply_control_data_output_group;
    end record;
    
    component system_components is
        port (
            system_clocks                : in system_clocks_group;
            system_components_FPGA_in    : in system_components_FPGA_input_group;
            system_components_FPGA_out   : out system_components_FPGA_output_group;
            system_components_FPGA_inout : inout system_components_FPGA_inout_record;
            system_components_data_in    : in system_components_data_input_group;
            system_components_data_out   : out system_components_data_output_group
        );
    end component system_components;
    
    -- signal system_components_clocks   : system_components_clock_group;
    -- signal system_components_FPGA_in  : system_components_FPGA_input_group;
    -- signal system_components_FPGA_out : system_components_FPGA_output_group;
    -- signal system_components_data_in  : system_components_data_input_group;
    -- signal system_components_data_out : system_components_data_output_group
    
    -- u_system_components : system_components
    -- port map( system_components_clocks,
    -- 	  system_components_FPGA_in,
    --	  system_components_FPGA_out,
    --	  system_components_data_in,
    --	  system_components_data_out); 

------------------------------------------------------------------------
end package system_components_pkg;
