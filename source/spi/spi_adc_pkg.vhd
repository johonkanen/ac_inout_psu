library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.spi_pkg.all;

package spi_adc_pkg is

    type spi_adc_record is record
        spi_cs : chip_select_record;
        spi_io_clock_group : spi_io_clock_record;
    end record;
    constant init_spi_Adc : spi_adc_record := (init_chip_select, init_spi_io_clock);

    procedure create_spi_adc (
        signal spi_adc : inout spi_adc_record);
    
end package spi_adc_pkg;


package body spi_adc_pkg is

    procedure create_spi_adc
    (
        signal spi_adc : inout spi_adc_record
    ) is
    begin
        create_chip_select(spi_adc.spi_cs);
        create_spi_io_clock(spi_adc.spi_io_clock_group);
    end create_spi_adc;

end package body spi_adc_pkg; 
