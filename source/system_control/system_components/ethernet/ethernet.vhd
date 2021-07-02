
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_pkg.all;

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

begin


------------------------------------------------------------------------

------------------------------------------------------------------------
end rtl;
