library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_pkg.all;

package mdio_driver_internal_pkg is

        function phy_command_is_transmitted ( counter : integer)
            return boolean;

        function phy_data_transmit_is_ready ( counter : integer)
            return boolean;

        function phy_command_address_is_transmitted ( counter : integer)
            return boolean;

        procedure transmit_phy_command_address (
            signal shift_register : out std_logic_vector(15 downto 0);
            phy_address : std_logic_vector(7 downto 0);     -- only last 5 bits are read
            register_address : std_logic_vector(7 downto 0)); -- only last 5 bits are read

        procedure set_mdio_direction_to_write (
            signal mdio_driver_FPGA_output : out mdio_driver_FPGA_output_group);

        procedure set_mdio_direction_to_read (
            signal mdio_driver_FPGA_output : out mdio_driver_FPGA_output_group);

end package mdio_driver_internal_pkg;

package body mdio_driver_internal_pkg is

    --------------------------------------------------
    procedure set_mdio_direction_to_write
    (
        signal mdio_driver_FPGA_output : out mdio_driver_FPGA_output_group
    ) is
    begin
        mdio_driver_FPGA_output.MDIO_io_direction_1_output <= '1';
        
    end set_mdio_direction_to_write;

    --------------------------------------------------
    procedure set_mdio_direction_to_read
    (
        signal mdio_driver_FPGA_output : out mdio_driver_FPGA_output_group
    ) is
    begin
        mdio_driver_FPGA_output.MDIO_io_direction_1_output <= '0';
        
    end set_mdio_direction_to_read;

    --------------------------------------------------
        impure function falling_edge ( clock_divisor : integer)
            return boolean is
        begin
            return clock_divisor = 2;
        end falling_edge;

    --------------------------------------------------
        impure function rising_edge ( clock_counter : integer)
            return boolean is
        begin
            return clock_counter = 1;
        end rising_edge;

    --------------------------------------------------
        function phy_command_is_transmitted
        (
            counter : integer
        )
        return boolean
        is
        begin
            return counter = 7;
        end phy_command_is_transmitted;

    --------------------------------------------------
        procedure transmit_phy_command_address
        (
            signal shift_register : out std_logic_vector(15 downto 0);
            phy_address : std_logic_vector(7 downto 0);     -- only last 5 bits are read
            register_address : std_logic_vector(7 downto 0) -- only last 5 bits are read
        ) is
        begin
            shift_register <= phy_address(4 downto 0) & register_address(4 downto 0) & "10" &x"0";
            
        end transmit_phy_command_address;

    --------------------------------------------------
        function phy_data_transmit_is_ready
        (
            counter : integer
        )
        return boolean
        is
        begin
            return counter = 28;
        end phy_data_transmit_is_ready;

    --------------------------------------------------
        function phy_command_address_is_transmitted
        (
            counter : integer
        )
        return boolean
        is
        begin
            return counter = 12;
        end phy_command_address_is_transmitted;


end package body mdio_driver_internal_pkg;

