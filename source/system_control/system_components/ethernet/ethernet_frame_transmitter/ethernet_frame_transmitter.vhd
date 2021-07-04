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
    
    constant counter_value_at_100kHz : natural := 1250;
    signal counter_for_100kHz : natural range 0 to 2**16-1 := counter_value_at_100kHz;

    constant counter_value_at_333ms : natural := 33e3;
    signal counter_for_333ms : natural range 0 to 2**16-1 := counter_value_at_333ms;

    signal transmit_byte_counter : natural range 0 to 255;


begin

    frame_transmitter : process(tx_ddr_clocks.tx_ddr_clock)
        
    begin
        if rising_edge(tx_ddr_clocks.tx_ddr_clock) then
            init_ethernet_tx_ddio(ethernet_tx_ddio_data_in);

            if counter_for_100kHz > 0 then
                counter_for_100kHz <= counter_for_100kHz - 1;
            else
                counter_for_100kHz <= counter_value_at_100kHz;

                if counter_for_333ms > 0 then
                    counter_for_333ms <= counter_for_333ms - 1;
                else
                    counter_for_333ms <= counter_value_at_333ms;
                    transmit_byte_counter <= 101;
                end if;
            end if; 

            if transmit_byte_counter > 0 then
                transmit_byte_counter <= transmit_byte_counter - 1;
                transmit_8_bits_of_data(ethernet_tx_ddio_data_in, transmit_byte_counter);
            end if; 

        end if; --rising_edge
    end process frame_transmitter;	

    u_ethernet_tx_ddio_pkg : ethernet_tx_ddio
    port map( tx_ddr_clocks                                                 ,
              ethernet_frame_transmitter_FPGA_out.ethernet_tx_ddio_FPGA_out ,
              ethernet_tx_ddio_data_in);

end rtl;
