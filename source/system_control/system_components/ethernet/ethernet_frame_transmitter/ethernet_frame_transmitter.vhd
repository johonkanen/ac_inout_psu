library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_transmitter_pkg.all;

entity ethernet_frame_transmitter is
    port (
        ethernet_frame_transmitter_clocks : in ethernet_frame_transmitter_clock_group; 
        ethernet_frame_transmitter_FPGA_out : out ethernet_frame_transmitter_FPGA_output_group; 
        ethernet_frame_transmitter_data_in : in ethernet_frame_transmitter_data_input_group;
        ethernet_frame_transmitter_data_out : out ethernet_frame_transmitter_data_output_group
    );
end entity ethernet_frame_transmitter;

architecture rtl of ethernet_frame_transmitter is

    

begin


end rtl;
