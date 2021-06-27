library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_three_state_io_driver_pkg.all;

entity mdio_three_state_io_driver is
    port (
        mdio_three_state_io_driver_clocks     : in mdio_three_state_io_driver_clock_group;
        mdio_three_state_io_driver_FPGA_inout : inout mdio_three_state_io_driver_FPGA_inout_record;
        mdio_three_state_io_driver_data_in    : in mdio_three_state_io_driver_data_input_group;
        mdio_three_state_io_driver_data_out   : out mdio_three_state_io_driver_data_output_group
    );
end entity;
