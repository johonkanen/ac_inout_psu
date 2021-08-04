library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_transmitter_pkg.all;
    use work.ethernet_frame_transmit_controller_pkg.all;
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
    
    constant counter_value_at_100kHz : natural := 12500;
    signal counter_for_100kHz : natural range 0 to 2**16-1 := counter_value_at_100kHz;

    constant counter_value_at_333ms : natural := 33e3/2;
    signal counter_for_333ms : natural range 0 to 2**16-1 := counter_value_at_333ms;

    signal fifo_is_not_almost_empty : boolean;

    signal data_from_fifo : std_logic_vector(7 downto 0);
    signal fcs_shift_register : std_logic_vector(31 downto 0);
    signal transmit_counter : natural range 0 to 511;
    signal frame_transmit_controller : frame_transmitter_record := init_transmit_controller;

    signal led_state : std_logic := '1';
    signal testicounter : natural range 0 to 255;
    signal transmit_is_requested : boolean;

begin

    ethernet_frame_transmitter_FPGA_out.led <= led_state;

    frame_transmitter : process(tx_ddr_clocks.tx_ddr_clock)
        
    begin
        if rising_edge(tx_ddr_clocks.tx_ddr_clock) then

        --------------------------------------------------
            if counter_for_100kHz > 0 then
                counter_for_100kHz <= counter_for_100kHz - 1;
            else
                counter_for_100kHz <= counter_value_at_100kHz;

                if counter_for_333ms > 0 then
                    counter_for_333ms <= counter_for_333ms - 1;
                else
                    counter_for_333ms <= counter_value_at_333ms;
                    transmit_ethernet_frame(frame_transmit_controller, 25);
                    led_state <= not led_state;
                end if;
            end if; 

        --------------------------------------------------
            init_ethernet_tx_ddio(ethernet_tx_ddio_data_in);
            create_transmit_controller(frame_transmit_controller);

            transmit_is_requested <= frame_transmit_controller.frame_transmitter_state /= idle;
            if frame_transmit_controller.frame_transmitter_state /= idle OR transmit_is_requested then
                transmit_8_bits_of_data(ethernet_tx_ddio_data_in, frame_transmit_controller.byte);
            end if;

        end if; --rising_edge
    end process frame_transmitter;	

------------------------------------------------------------------------
    -- u_tx_fifo : tx_fifo
	-- PORT map
	-- (
	-- 	clock        => tx_ddr_clocks.tx_ddr_clock    ,
	-- 	data         => fifo_data_input.data          ,
	-- 	rdreq        => fifo_data_input.rdreq         ,
	-- 	wrreq        => fifo_data_input.wrreq         ,
	-- 	almost_empty => fifo_data_output.almost_empty ,
	-- 	empty        => fifo_data_output.empty        ,
	-- 	q            => fifo_data_output.q            
	-- );

------------------------------------------------------------------------
    u_ethernet_tx_ddio_pkg : ethernet_tx_ddio
    port map( tx_ddr_clocks                                                 ,
              ethernet_frame_transmitter_FPGA_out.ethernet_tx_ddio_FPGA_out ,
              ethernet_tx_ddio_data_in);

------------------------------------------------------------------------
end rtl;
