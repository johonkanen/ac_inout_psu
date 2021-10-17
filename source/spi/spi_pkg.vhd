library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package spi_pkg is

------------------------------------------------------------------------
    type spi_io_clock_record is record
        clock_division_counter    : natural range 0 to 2**8-1;
        spi_io_clock              : std_logic;
        spi_clock_division        : natural;
        number_of_clocks_in_frame : natural;
        spi_clock_counter         : natural;
    end record;
------------------------------------------------------------------------
    constant init_spi_io_clock : spi_io_clock_record := (4,'1',5, 8, 0);

------------------------------------------------------------------------
    procedure create_spi_io_clock (
        signal spi_clock_group : inout spi_io_clock_record);

    procedure set_clock_division (
        signal spi_clock_group : inout spi_io_clock_record;
        clock_divider : in natural);

    procedure request_spi_clock (
        signal spi_clock_group : inout spi_io_clock_record;
        number_of_spi_clocks : in natural);

------------------------------------------------------------------------
    type chip_select_record is record
        spi_chip_select : std_logic;
        process_counter : natural;
        test_counter : natural;
    end record;
------------------------------------------------------------------------
    constant init_chip_select : chip_select_record := ('0',0, 0);

------------------------------------------------------------------------
    procedure create_chip_select (
        signal spi_chip_select : inout chip_select_record); 

------------------------------------------------------------------------
end package spi_pkg;


package body spi_pkg is

------------------------------------------------------------------------
    procedure create_spi_io_clock
    (
        signal spi_clock_group : inout spi_io_clock_record
    ) is
        alias clock_division_counter is spi_clock_group.clock_division_counter;
        alias spi_io_clock is spi_clock_group.spi_io_clock;
        alias spi_clock_division is spi_clock_group.spi_clock_division;
        alias spi_clock_counter is spi_clock_group.spi_clock_counter;
    begin
        --------------------------------------------------
        if spi_clock_counter > 0 then
            if clock_division_counter > 0 then
                clock_division_counter <= clock_division_counter - 1;
            end if;

            if clock_division_counter = 0 then
                clock_division_counter <= spi_clock_division;
            end if;

            spi_io_clock <= '1';
            if clock_division_counter > spi_clock_division/2 then
                spi_io_clock <= '0';
            end if;
            --------------------------------------------------
            if clock_division_counter = 1 then
                spi_clock_counter <= spi_clock_counter - 1;
            end if;
        end if;
        -------------------------------------------------- 
        --------------------------------------------------
    end create_spi_io_clock;

------------------------------------------------------------------------
    procedure set_clock_division
    (
        signal spi_clock_group : inout spi_io_clock_record;
        clock_divider : in natural
    ) is
    begin
        spi_clock_group.spi_clock_division <= clock_divider; 
        spi_clock_group.spi_clock_division <= clock_divider; 
    end set_clock_division;
------------------------------------------------------------------------
    procedure request_spi_clock
    (
        signal spi_clock_group : inout spi_io_clock_record;
        number_of_spi_clocks : in natural
    ) is
    begin
        spi_clock_group.spi_clock_counter <= number_of_spi_clocks;
        spi_clock_group.spi_io_clock <= '0';        
        
    end request_spi_clock;

------------------------------------------------------------------------
------------------------------------------------------------------------
    procedure create_chip_select
    (
        signal spi_chip_select : inout chip_select_record
    ) is
    begin

        spi_chip_select.test_counter <= spi_chip_select.test_counter + 1;

        spi_chip_select.spi_chip_select <= '1';
        if spi_chip_select.test_counter > 5 then
            spi_chip_select.spi_chip_select <= '0';
        end if;

        if spi_chip_select.test_counter > 15 then 
            spi_chip_select.spi_chip_select <= '1';
        end if;
        
    end create_chip_select;
------------------------------------------------------------------------ 
end package body spi_pkg; 
