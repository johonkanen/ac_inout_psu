
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_pkg.all;
    use work.mdio_interface_pkg.all;

entity ethernet is
    port (
        ethernet_clocks   : in ethernet_clock_group;
        ethernet_FPGA_in  : in ethernet_FPGA_input_group;
        ethernet_FPGA_out : out ethernet_FPGA_output_group;
        ethernet_data_in  : in ethernet_data_input_group;
        ethernet_data_out : out ethernet_data_output_group
    );
end entity;

architecture rtl of ethernet is

--------------------------------------------------

    signal mdio_interface_clocks   : mdio_interface_clock_group;
    signal mdio_interface_data_out : mdio_interface_data_output_group;

begin

    ethernet_data_out <= (mdio_interface_data_out => mdio_interface_data_out);

------------------------------------------------------------------------
    mdio_interface_clocks <= (clock   => ethernet_clocks.core_clock,
                              reset_n => '1');

    u_mdio_interface : mdio_interface
    port map(
        mdio_interface_clocks,
        ethernet_FPGA_in.mdio_interface_FPGA_in,
        ethernet_FPGA_out.mdio_interface_FPGA_out,
        ethernet_data_in.mdio_interface_data_in, 
        mdio_interface_data_out);

------------------------------------------------------------------------
end rtl;
