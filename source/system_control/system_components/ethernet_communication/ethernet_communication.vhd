library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_communication_pkg.all;
    use work.ethernet_pkg.all;


entity ethernet_communication is
    port (
        ethernet_communication_clocks     : in  ethernet_clock_group;
        ethernet_communication_FPGA_in    : in  ethernet_communication_FPGA_input_group;
        ethernet_communication_FPGA_out   : out ethernet_communication_FPGA_output_group;
        ethernet_communication_FPGA_inout : inout ethernet_communication_FPGA_inout_record;
        ethernet_communication_data_in    : in  ethernet_communication_data_input_group;
        ethernet_communication_data_out   : out ethernet_communication_data_output_group
    );
end entity ethernet_communication;

architecture rtl of ethernet_communication is

    alias clock is ethernet_communication_clocks.core_clock;

    
    signal ethernet_clocks     : ethernet_clock_group;
    signal ethernet_FPGA_in    : ethernet_FPGA_input_group;
    signal ethernet_FPGA_out   : ethernet_FPGA_output_group;
    signal ethernet_FPGA_inout : ethernet_FPGA_inout_record;
    signal ethernet_data_in    : ethernet_data_input_group;
    signal ethernet_data_out   : ethernet_data_output_group;


begin

------------------------------------------------------------------------ 
    u_ethernet : ethernet
    port map( ethernet_communication_clocks                         ,
              ethernet_communication_FPGA_in.ethernet_FPGA_in       ,
              ethernet_communication_FPGA_out.ethernet_FPGA_out     ,
              ethernet_communication_FPGA_inout.ethernet_FPGA_inout ,
              ethernet_communication_data_in.ethernet_data_in                                      ,
              ethernet_communication_data_out.ethernet_data_out);

------------------------------------------------------------------------ 

end rtl;
