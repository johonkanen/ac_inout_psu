library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.power_supply_control_pkg.all;
    use work.uart_pkg.all;
    use work.spi_sar_adc_pkg.all;

package system_components_pkg is

    type system_components_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type system_components_FPGA_input_group is record
        power_supply_control_FPGA_in : power_supply_control_FPGA_input_group;
        uart_FPGA_in                 : uart_FPGA_input_group;
        spi_sar_adc_FPGA_in          : spi_sar_adc_FPGA_input_group;
    end record;
    
    type system_components_FPGA_output_group is record
        power_supply_control_FPGA_out : power_supply_control_FPGA_output_group;
        uart_FPGA_out                 : uart_FPGA_output_group;
        spi_sar_adc_FPGA_out          : spi_sar_adc_FPGA_output_group;
        test_ad_mux                  : std_logic_vector(2 downto 0);
    end record;
    
    type system_components_data_input_group is record
        power_supply_control_data_in : power_supply_control_data_input_group;
    end record;
    
    type system_components_data_output_group is record
        power_supply_control_data_out : power_supply_control_data_output_group;
    end record;
    
    component system_components is
        port (
            system_components_clocks : in system_components_clock_group; 
            system_components_FPGA_in : in system_components_FPGA_input_group;
            system_components_FPGA_out : out system_components_FPGA_output_group; 
            system_components_data_in : in system_components_data_input_group;
            system_components_data_out : out system_components_data_output_group
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
