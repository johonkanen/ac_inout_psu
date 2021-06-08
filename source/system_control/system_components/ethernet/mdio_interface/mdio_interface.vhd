library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_interface_pkg.all;
    use work.mdio_driver_pkg.all;

entity mdio_interface is
    port (
        mdio_interface_clocks   : in mdio_interface_clock_group;
        mdio_interface_FPGA_in  : in mdio_interface_FPGA_input_group;
        mdio_interface_FPGA_out : out mdio_interface_FPGA_output_group;
        mdio_interface_data_in  : in mdio_interface_data_input_group;
        mdio_interface_data_out : out mdio_interface_data_output_group
    );
end entity;

architecture rtl of mdio_interface is

    alias core_clock is mdio_interface_clocks.clock;
    alias reset_n is mdio_interface_clocks.reset_n;

    alias mmd_read_is_requested is mdio_interface_data_in.mmd_read_is_requested;
    alias mmd_write_is_requested is mdio_interface_data_in.mmd_write_is_requested;

    signal mdio_driver_clocks   : mdio_driver_clock_group;
    signal mdio_driver_data_in  : mdio_driver_data_input_group;
    signal mdio_driver_data_out : mdio_driver_data_output_group;
    
    constant phy_address : std_logic_vector := x"00";
    constant mmd_access_control_register : std_logic_vector := x"0d";
    constant mmd_access_data_register : std_logic_vector := x"0e";

    constant reserved                                            : std_logic_vector(13 downto 5) := (others => '0');
    constant mmd_register_address                                : std_logic_vector              := "00" & reserved;
    constant mmd_data_at_mmd_address                             : std_logic_vector              := "01" & reserved;
    constant mmd_data_at_mmd_address_and_increment_address       : std_logic_vector              := "10" & reserved;
    constant write_mmd_data_at_mmd_address_and_increment_address : std_logic_vector              := "11" & reserved;

    constant device_address : std_logic_vector := '0' & x"0"; -- unknown at this time

    signal process_counter : integer range 0 to 15;

------------------------------------------------------------------------
begin


------------------------------------------------------------------------
    MMD_access_controller : process(core_clock)
        type t_mmd_access_control is (idle, read_mmd_data, write_mmd_data);
        
        variable st_mmd_access_control : t_mmd_access_control;

    begin
        if rising_edge(core_clock) then
            if reset_n = '0' then
            -- reset state
                process_counter <= 0;
    
            else

                mdio_driver_data_in <= mdio_interface_data_in.mdio_driver_data_in;
                mdio_interface_data_out.mdio_driver_data_out <= mdio_driver_data_out;

                mdio_interface_data_out.mmd_is_ready <= false;
                CASE st_mmd_access_control is
                    WHEN idle =>
                        process_counter <= 0;

                        if mmd_read_is_requested then
                            st_mmd_access_control := read_mmd_data;
                            write_data_to_mdio(mdio_driver_data_in,phy_address, mmd_access_data_register, mdio_interface_data_in.mmd_address);
                        end if;

                        if mmd_write_is_requested then
                            st_mmd_access_control := read_mmd_data;
                            write_data_to_mdio(mdio_driver_data_in,phy_address, mmd_access_data_register, mdio_interface_data_in.mmd_address);
                        end if;


                ------------- read data from mmd -----------------
                    WHEN read_mmd_data =>

                        st_mmd_access_control := read_mmd_data;
                        if mdio_is_ready(mdio_driver_data_out) then
                            CASE process_counter is
                                WHEN 0 =>
                                    process_counter <= process_counter + 1;
                                    write_data_to_mdio(mdio_driver_data_in, phy_address, mmd_access_control_register, mmd_register_address & device_address);

                                WHEN 1 =>
                                    process_counter <= process_counter + 1;
                                    read_data_from_mdio(mdio_driver_data_in, phy_address, mmd_access_data_register);

                                WHEN 2 =>
                                    mdio_interface_data_out.data_from_mmd <= get_data_from_mdio(mdio_driver_data_out);
                                    st_mmd_access_control := idle;
                                    mdio_interface_data_out.mmd_is_ready <= true;

                                WHEN others => 
                                    st_mmd_access_control := idle;
                            end CASE;
                        end if;

                ------------- write data to mmd -----------------
                    WHEN write_mmd_data =>

                        st_mmd_access_control := write_mmd_data;
                        if mdio_is_ready(mdio_driver_data_out) then
                            CASE process_counter is
                                WHEN 0 => -- write access function
                                    process_counter <= process_counter + 1;
                                    write_data_to_mdio(mdio_driver_data_in, phy_address, mmd_access_control_register, mmd_register_address & device_address);

                                WHEN 1 => -- write mmd data to register
                                    process_counter <= process_counter + 1;
                                    write_data_to_mdio(mdio_driver_data_in, phy_address, mmd_access_data_register, mmd_register_address & device_address);

                                WHEN 2 => -- write access function
                                    process_counter <= process_counter + 1;
                                    write_data_to_mdio(mdio_driver_data_in, phy_address, mmd_access_control_register, mmd_register_address & device_address);


                                WHEN 3 => -- load data from register to mmd
                                    mdio_interface_data_out.mmd_is_ready <= true;
                                    st_mmd_access_control := idle;

                                WHEN others => 
                                    st_mmd_access_control := idle;
                            end CASE;
                        end if;
                end CASE;
    
            end if; -- rstn
        end if; --rising_edge
    end process MMD_access_controller;	

------------------------------------------------------------------------
    mdio_driver_clocks <= (clock => core_clock,
                          reset_n => reset_n);

    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks,
        mdio_interface_FPGA_in.mdio_driver_FPGA_in,
        mdio_interface_FPGA_out.mdio_driver_FPGA_out,
        mdio_driver_data_in, 
        mdio_driver_data_out);
------------------------------------------------------------------------

end rtl;

