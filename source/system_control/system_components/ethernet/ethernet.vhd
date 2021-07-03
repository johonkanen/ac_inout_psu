
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_pkg.all;
    use work.mdio_driver_pkg.all;

entity ethernet is
    port (
        ethernet_clocks     : in ethernet_clock_group;
        ethernet_FPGA_in    : in ethernet_FPGA_input_group;
        ethernet_FPGA_out   : out ethernet_FPGA_output_group;
        ethernet_FPGA_inout : inout ethernet_FPGA_inout_record;
        ethernet_data_in    : in ethernet_data_input_group;
        ethernet_data_out   : out ethernet_data_output_group
    );
end entity;

architecture rtl of ethernet is

--------------------------------------------------
    signal mdio_driver_clocks : mdio_driver_clock_group;

begin


------------------------------------------------------------------------
------------------------------------------------------------------------ 
    mdio_driver_clocks <= (clock => ethernet_clocks.core_clock);
    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        ethernet_FPGA_out.mdio_driver_FPGA_out ,
        ethernet_FPGA_inout.mdio_driver_FPGA_inout ,
        ethernet_data_in.mdio_driver_data_in  ,
        ethernet_data_out.mdio_driver_data_out); 

------------------------------------------------------------------------
end rtl;
