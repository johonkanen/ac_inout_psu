library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_mmd_access_control_pkg.all;
    use work.mdio_driver_pkg.all;

entity mdio_mmd_access_control is
    port (
        mdio_mmd_access_control_clocks   : in mdio_mmd_access_control_clock_group;
        mdio_mmd_access_control_FPGA_in  : in mdio_mmd_access_control_FPGA_input_group;
        mdio_mmd_access_control_FPGA_out : out mdio_mmd_access_control_FPGA_output_group;
        mdio_mmd_access_control_data_in  : in mdio_mmd_access_control_data_input_group;
        mdio_mmd_access_control_data_out : out mdio_mmd_access_control_data_output_group
    );
end entity;

architecture rtl of mdio_mmd_access_control is

    alias core_clock is mdio_mmd_access_control_clocks.clock;
    alias reset_n is mdio_mmd_access_control_clocks.reset_n;

    alias mmd_read_is_requested is mdio_mmd_access_control_data_in.mmd_read_is_requested;
    alias mmd_write_is_requested is mdio_mmd_access_control_data_in.mmd_write_is_requested;

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
        end if; --rising_edge
    end process MMD_access_controller;	

------------------------------------------------------------------------
    mdio_driver_clocks <= (clock => core_clock);

    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks,
        mdio_mmd_access_control_FPGA_out.mdio_driver_FPGA_out,
        mdio_driver_data_in, 
        mdio_driver_data_out);
------------------------------------------------------------------------

end rtl;

