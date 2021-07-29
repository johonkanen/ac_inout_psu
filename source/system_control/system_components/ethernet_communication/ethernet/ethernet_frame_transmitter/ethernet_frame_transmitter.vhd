library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_transmitter_pkg.all;
    use work.ethernet_frame_transmitter_internal_pkg.all;
    use work.ethernet_tx_ddio_pkg.all;
    use work.PCK_CRC32_D8.all;

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
    signal byte_counter_offset : natural range 0 to 255 := 0; 


    signal transmit_control : frame_transmit_control_group;

    type list_of_transmit_ddr_states is (wait_for_start, transmit_fifo, transmit_fcs);
    signal transmit_ddr_state : list_of_transmit_ddr_states;
    signal fifo_is_not_almost_empty : boolean;

    signal data_from_fifo : std_logic_vector(7 downto 0);
    signal fcs_shift_register : std_logic_vector(31 downto 0);
    signal transmit_counter : natural range 0 to 511;

    signal fifo_data_input : fifo_input_control_group;
    signal fifo_data_output         : fifo_output_control_group;
    signal transmitter_is_enabled : boolean;

begin

    frame_transmitter : process(tx_ddr_clocks.tx_ddr_clock)
        
    begin
        if rising_edge(tx_ddr_clocks.tx_ddr_clock) then

            if counter_for_100kHz > 0 then
                counter_for_100kHz <= counter_for_100kHz - 1;
            else
                counter_for_100kHz <= counter_value_at_100kHz;

                if counter_for_333ms > 0 then
                    counter_for_333ms <= counter_for_333ms - 1;
                else
                    counter_for_333ms <= counter_value_at_333ms;
                    transmit_byte_counter <= 101;
                    byte_counter_offset <= byte_counter_offset + 1;
                end if;
            end if; 

        --------------------------------------------------
            init_ethernet_tx_ddio(ethernet_tx_ddio_data_in);
            create_transmit_controller(transmit_control, ethernet_tx_ddio_data_in);

            CASE transmit_ddr_state is
                WHEN wait_for_start =>
                WHEN transmit_fifo =>
                    if fifo_is_not_almost_empty then
                        -- read_word_from_fifo(fifo);
                        -- transmit_8_bits_of_data(ethernet_tx_ddio_data_in, data_from_fifo);
                        fcs_shift_register <= nextCRC32_D8(data_from_fifo, fcs_shift_register);
                        transmit_counter <= 3;
                    end if;

                WHEN transmit_fcs =>
                    if transmit_counter > 0 then
                        transmit_counter <= transmit_counter - 1;
                    else
                        transmit_ddr_state <= wait_for_start;
                    end if;
                    fcs_shift_register <= fcs_shift_register(23 downto 0) & x"FF";
                    -- transmit_8_bits_of_data(ethernet_tx_ddio_data_in, fcs_shift_register(31 downto 24));
            end CASE;

            if transmit_counter > 0 then
                -- transmit_counter <= transmit_counter - 1;
            end if;

            init_fifo(fifo_data_input);
            if transmit_counter > 1 then
                write_data_to_fifo(fifo_data_input, x"AA");
                transmitter_is_enabled <= false;
            elsif transmit_counter = 1 then
                write_data_to_fifo(fifo_data_input, x"AB");
                transmitter_is_enabled <= false;
            else -- do nothing, wait for transmit counter to be set
                transmitter_is_enabled <= true;
            end if;

            if fifo_is_not_almost_empty and transmitter_is_enabled then
                -- transmit_8_bits_of_data(ethernet_tx_ddio_data_in, data_from_fifo);
            end if;

        end if; --rising_edge
    end process frame_transmitter;	

------------------------------------------------------------------------
    u_tx_fifo : tx_fifo
	PORT map
	(
		clock        => tx_ddr_clocks.tx_ddr_clock    ,
		data         => fifo_data_input.data          ,
		rdreq        => fifo_data_input.rdreq         ,
		wrreq        => fifo_data_input.wrreq         ,
		almost_empty => fifo_data_output.almost_empty ,
		empty        => fifo_data_output.empty        ,
		q            => fifo_data_output.q            
	);

------------------------------------------------------------------------
    u_ethernet_tx_ddio_pkg : ethernet_tx_ddio
    port map( tx_ddr_clocks                                                 ,
              ethernet_frame_transmitter_FPGA_out.ethernet_tx_ddio_FPGA_out ,
              ethernet_tx_ddio_data_in);

------------------------------------------------------------------------
end rtl;
