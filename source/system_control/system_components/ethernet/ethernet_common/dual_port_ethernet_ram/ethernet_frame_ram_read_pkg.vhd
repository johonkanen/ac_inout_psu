library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package ethernet_frame_ram_read_pkg is
------------------------------------------------------------------------
        type ram_read_control_group is record
            address : std_logic_vector(10 downto 0);
            read_is_enabled_when_1 : std_logic;
        end record; 
------------------------------------------------------------------------
        type ram_read_output_group is record
            data_is_ready : boolean;
            byte_from_ram : std_logic_vector(7 downto 0);
        end record;
------------------------------------------------------------------------ 
    procedure init_ram_read (
        signal ram_read_port : out ram_read_control_group);
------------------------------------------------------------------------
    procedure read_data_from_ram (
        signal ram_read_port : out ram_read_control_group;
        offset : natural;
        address : natural);
------------------------------------------------------------------------
    procedure read_data_from_ram (
        signal ram_read_port : out ram_read_control_group;
        address : natural);
------------------------------------------------------------------------
------------------------------------------------------------------------

end package ethernet_frame_ram_read_pkg;


package body ethernet_frame_ram_read_pkg is
------------------------------------------------------------------------
    procedure init_ram_read
    (
        signal ram_read_port : out ram_read_control_group
    ) is
    begin
        ram_read_port.read_is_enabled_when_1 <= '0'; 
    end init_ram_read;

------------------------------------------------------------------------
    procedure read_data_from_ram
    (
        signal ram_read_port : out ram_read_control_group;
        address : natural
    ) is
    begin
        ram_read_port.read_is_enabled_when_1 <= '1';
        ram_read_port.address <= std_logic_vector(to_unsigned(address, 11));

    end read_data_from_ram;
------------------------------------------------------------------------
    procedure read_data_from_ram
    (
        signal ram_read_port : out ram_read_control_group;
        offset : natural;
        address : natural
    ) is
    begin
        ram_read_port.read_is_enabled_when_1 <= '1';
        ram_read_port.address <= std_logic_vector(to_unsigned(offset + address, 11));

    end read_data_from_ram;

------------------------------------------------------------------------

end package body ethernet_frame_ram_read_pkg;

