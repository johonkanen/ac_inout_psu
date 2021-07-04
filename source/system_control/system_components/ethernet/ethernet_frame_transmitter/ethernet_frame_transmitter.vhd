library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_transmitter_pkg.all;
    use work.ethernet_tx_ddio_pkg.all;

entity ethernet_frame_transmitter is
    port (
        tx_ddr_clocks                       : in ethernet_tx_ddr_clock_group;
        ethernet_frame_transmitter_FPGA_out : out ethernet_frame_transmitter_FPGA_output_group;
        ethernet_frame_transmitter_data_in  : in ethernet_frame_transmitter_data_input_group;
        ethernet_frame_transmitter_data_out : out ethernet_frame_transmitter_data_output_group
    );
end entity ethernet_frame_transmitter;

architecture rtl of ethernet_frame_transmitter is

    
    signal ethernet_tx_ddio_clocks   : ethernet_tx_ddr_clock_group;
    signal ethernet_tx_ddio_FPGA_out : ethernet_tx_ddio_FPGA_output_group;
    signal ethernet_tx_ddio_data_in  : ethernet_tx_ddio_data_input_group;
    

begin

    frame_transmitter : process(tx_ddr_clocks.tx_ddr_clock)
        
    begin
        if rising_edge(tx_ddr_clocks.tx_ddr_clock) then
            init_ethernet_tx_ddio(ethernet_tx_ddio_data_in);

        end if; --rising_edge
    end process frame_transmitter;	

    u_ethernet_tx_ddio_pkg : ethernet_tx_ddio
    port map( tx_ddr_clocks                                                 ,
              ethernet_frame_transmitter_FPGA_out.ethernet_tx_ddio_FPGA_out ,
              ethernet_tx_ddio_data_in);

end rtl;
