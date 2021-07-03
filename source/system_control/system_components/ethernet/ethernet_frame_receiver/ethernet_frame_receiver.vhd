library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_rx_ddio_pkg.all;


entity ethernet_frame_receiver is
    port (
        ethernet_frame_receiver_clocks   : in ethernet_clock_group;
        ethernet_frame_receiver_FPGA_in  : in ethernet_frame_receiver_FPGA_input_group;
        ethernet_frame_receiver_data_in  : in ethernet_frame_receiver_data_input_group;
        ethernet_frame_receiver_data_out : out ethernet_frame_receiver_data_output_group
    );
end entity ethernet_frame_receiver;

architecture rtl of ethernet_frame_receiver is

    signal ethernet_rx_ddio_clocks   : ethernet_clock_group;
    signal ethernet_rx_ddio_FPGA_in : ethernet_rx_ddio_FPGA_input_group;
    signal ethernet_rx_ddio_data_out  : ethernet_rx_ddio_data_output_group;

    alias rx_ddr_clock is ethernet_rx_ddio_clocks.rx_ddr_clocks.rx_ddr_clock;

    type bytearray is array (integer range <>) of std_logic_vector(7 downto 0); 
    signal stuff : bytearray(0 to 46);

    signal rx_shift_register : std_logic_vector(15 downto 0); 
    
begin

    frame_receiver : process(rx_ddr_clock) 
    begin
        if rising_edge(rx_ddr_clock) then

            rx_shift_register <= rx_shift_register(7 downto 0) & get_byte(ethernet_rx_ddio_data_out); 

        end if; --rising_edge
    end process frame_receiver;	

    u_ethernet_rx_ddio_pkg : ethernet_rx_ddio
    port map( ethernet_rx_ddio_clocks  ,
              ethernet_rx_ddio_FPGA_in ,
              ethernet_rx_ddio_data_out);

end rtl;
