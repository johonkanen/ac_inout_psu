library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_internal_pkg.all;
    use work.mdio_driver_pkg.all;

entity mdio_driver is
    port (
        mdio_driver_clocks : in mdio_driver_clock_group;

        mdio_driver_FPGA_out : out mdio_driver_FPGA_output_group; 
        mdio_driver_data_in  : in mdio_driver_data_input_group;
        mdio_driver_data_out : out mdio_driver_data_output_group
    );
end mdio_driver;

architecture rtl of mdio_driver is

    alias core_clock is mdio_driver_clocks.clock; 
    signal mdio_transmit_control : mdio_transmit_control_group := mdio_transmit_control_init;

begin

    mdio_driver_FPGA_out <= ( 
                            MDIO_serial_data_out            => mdio_transmit_control.mdio_transmit_register(mdio_transmit_control.mdio_transmit_register'left) ,
                            MDIO_io_direction_is_out_when_1 => '1'                                              ,
                            MDIO_clock                      => mdio_transmit_control.mdio_clock);

------------------------------------------------------------------------
    mdio_io_driver : process(core_clock)

    --------------------------------------------------
        type list_of_mdio_states is (idle, transmit_command, transmit_address);
        variable mdio_state : list_of_mdio_states;

    --------------------------------------------------
    begin
        if rising_edge(core_clock) then

            generate_mdio_io_waveforms(mdio_transmit_control); 

            if mdio_driver_data_in.mdio_data_write_is_requested then
                write_data_to_mdio(mdio_transmit_control, MDIO_write_command             &
                                    mdio_driver_data_in.phy_address(4 downto 0)          &
                                    mdio_driver_data_in.phy_register_address(4 downto 0) &
                                    mdio_driver_data_in.data_to_mdio(15 downto 0));
            end if;

        end if; --rising_edge
    end process mdio_io_driver;	
end rtl;
