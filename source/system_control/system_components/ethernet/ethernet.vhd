
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_pkg.all;
    use work.mdio_mmd_access_control_pkg.all;

entity ethernet is
    port (
        ethernet_clocks   : in ethernet_clock_group;
        ethernet_FPGA_in  : in ethernet_FPGA_input_group;
        ethernet_FPGA_out : out ethernet_FPGA_output_group;
        ethernet_FPGA_inout : inout ethernet_FPGA_inout_record;
        ethernet_data_in  : in ethernet_data_input_group;
        ethernet_data_out : out ethernet_data_output_group
    );
end entity;

architecture rtl of ethernet is

--------------------------------------------------

    signal mdio_mmd_access_control_clocks   : mdio_mmd_access_control_clock_group;
    signal mdio_mmd_access_control_data_out : mdio_mmd_access_control_data_output_group;

begin

    ethernet_data_out <= (mdio_mmd_access_control_data_out => mdio_mmd_access_control_data_out);

------------------------------------------------------------------------
    mdio_mmd_access_control_clocks <= (clock   => ethernet_clocks.core_clock,
                              reset_n => '1');

    u_mdio_mmd_access_control : mdio_mmd_access_control
    port map(
        mdio_mmd_access_control_clocks,
        ethernet_FPGA_out.mdio_mmd_access_control_FPGA_out,
        ethernet_FPGA_inout.mdio_mmd_access_control_FPGA_inout,
        ethernet_data_in.mdio_mmd_access_control_data_in, 
        mdio_mmd_access_control_data_out);

------------------------------------------------------------------------
end rtl;
