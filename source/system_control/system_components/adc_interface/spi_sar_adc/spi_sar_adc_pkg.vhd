library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package spi_sar_adc_pkg is

    type spi_sar_adc_clock_group is record
        clock : std_logic;
    end record;
    
    type spi_sar_adc_FPGA_input_group is record
        spi_serial_data : std_logic;
    end record;
    
    type spi_sar_adc_FPGA_output_group is record
        chip_select : std_logic;
        spi_clock : std_logic;
    end record;
    
    type spi_sar_adc_data_input_group is record
        ad_conversion_started_with_1 : std_logic;
    end record;
    
    type spi_sar_adc_data_output_group is record
        ad_measurement_data : natural range 0 to 2**16-1;
        adc_conversion_is_ready_when_1 : std_logic;
    end record;
    
    component spi_sar_adc is
        port (
            spi_sar_adc_clocks   : in spi_sar_adc_clock_group;
            spi_sar_adc_FPGA_in  : in spi_sar_adc_FPGA_input_group;
            spi_sar_adc_FPGA_out : out spi_sar_adc_FPGA_output_group;
            spi_sar_adc_data_in  : in spi_sar_adc_data_input_group;
            spi_sar_adc_data_out : out spi_sar_adc_data_output_group
        );
    end component spi_sar_adc;
    
    -- signal spi_sar_adc_clocks   : spi_sar_adc_clock_group;
    -- signal spi_sar_adc_FPGA_in  : spi_sar_adc_FPGA_input_group;
    -- signal spi_sar_adc_FPGA_out : spi_sar_adc_FPGA_output_group;
    -- signal spi_sar_adc_data_in  : spi_sar_adc_data_input_group;
    -- signal spi_sar_adc_data_out : spi_sar_adc_data_output_group
    
    -- u_spi_sar_adc : spi_sar_adc
    -- port map( spi_sar_adc_clocks,
    -- 	  spi_sar_adc_FPGA_in,
    --	  spi_sar_adc_FPGA_out,
    --	  spi_sar_adc_data_in,
    --	  spi_sar_adc_data_out);

------------------------------------------------------------------------
    procedure idle_adc (
        signal adc_input : out spi_sar_adc_data_input_group);
------------------------------------------------------------------------
    procedure start_ad_conversion (
        signal adc_input : out spi_sar_adc_data_input_group);
------------------------------------------------------------------------
    function ad_conversion_is_ready ( adc_output : spi_sar_adc_data_output_group)
        return boolean;
------------------------------------------------------------------------
    function get_adc_data ( adc_output : spi_sar_adc_data_output_group)
        return integer;
    

end package spi_sar_adc_pkg;

package body spi_sar_adc_pkg is

------------------------------------------------------------------------
    procedure idle_adc
    (
        signal adc_input : out spi_sar_adc_data_input_group
    ) is
    begin
        adc_input.ad_conversion_started_with_1 <= '0';
        
    end idle_adc;

------------------------------------------------------------------------
    procedure start_ad_conversion
    (
        signal adc_input : out spi_sar_adc_data_input_group
    ) is
    begin
        adc_input.ad_conversion_started_with_1 <= '1';
    end start_ad_conversion;

------------------------------------------------------------------------
    function ad_conversion_is_ready
    (
        adc_output : spi_sar_adc_data_output_group
    )
    return boolean
    is
    begin
        if adc_output.adc_conversion_is_ready_when_1 = '1' then
            return true;
        else 
            return false;
        end if;
        
    end ad_conversion_is_ready;

------------------------------------------------------------------------
    function get_adc_data
    (
        adc_output : spi_sar_adc_data_output_group
    )
    return integer
    is
    begin
        return adc_output.ad_measurement_data;
    end get_adc_data;

------------------------------------------------------------------------
end package body spi_sar_adc_pkg; 
