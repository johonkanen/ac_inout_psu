library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_communication_pkg.all;


entity ethernet_communication is
    port (
        ethernet_communication_clocks     : in  ethernet_clock_group;
        ethernet_communication_FPGA_in    : in  ethernet_communication_FPGA_input_group;
        ethernet_communication_FPGA_out   : out ethernet_communication_FPGA_output_group;
        ethernet_communication_FPGA_inout : out ethernet_communication_FPGA_inout_record;
        ethernet_communication_data_in    : in  ethernet_communication_data_input_group;
        ethernet_communication_data_out   : out ethernet_communication_data_output_group
    );
end entity ethernet_communication;

architecture rtl of ethernet_communication is

    

begin


end rtl;
