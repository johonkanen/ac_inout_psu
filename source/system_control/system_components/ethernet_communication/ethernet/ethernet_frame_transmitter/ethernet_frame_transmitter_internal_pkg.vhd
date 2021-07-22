library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_transmitter_pkg.all;
    use work.ethernet_tx_ddio_pkg.all;


package ethernet_frame_transmitter_internal_pkg is
------------------------------------------------------------------------

    type list_of_transmitter_states is (wait_for_transmit_request, transmit_preamble, transmit_data, transmit_fcs);

    type frame_transmit_control_group is record
        transmitter_state : list_of_transmitter_states;
        transmitter_counter : natural range 0 to 2047;
    end record;

    --------------------------------------------------
    procedure create_transmit_controller (
        signal transmit_controller : inout frame_transmit_control_group;
        signal ethernet_tx_ddio_input : out ethernet_tx_ddio_data_input_group);
    --------------------------------------------------

------------------------------------------------------------------------
end package ethernet_frame_transmitter_internal_pkg;


package body ethernet_frame_transmitter_internal_pkg is
------------------------------------------------------------------------
    procedure create_transmit_controller
    (
        signal transmit_controller    : inout frame_transmit_control_group;
        signal ethernet_tx_ddio_input : out ethernet_tx_ddio_data_input_group
    ) is
        alias transmitter_state is transmit_controller.transmitter_state;
        alias transmitter_counter is transmit_controller.transmitter_counter;
    begin

        CASE transmitter_state is
            WHEN wait_for_transmit_request => 
                transmitter_counter <= 56;

            WHEN transmit_preamble =>

                if transmitter_counter > 0 then
                    transmit_8_bits_of_data(ethernet_tx_ddio_input, x"AA");
                    transmitter_counter <= transmitter_counter - 1;
                else
                    transmit_8_bits_of_data(ethernet_tx_ddio_input, x"AB");
                    transmitter_state <= transmit_data;
                end if;

            WHEN transmit_data =>
            WHEN transmit_fcs  =>
        end CASE;
        
    end create_transmit_controller;

------------------------------------------------------------------------
end package body ethernet_frame_transmitter_internal_pkg; 
