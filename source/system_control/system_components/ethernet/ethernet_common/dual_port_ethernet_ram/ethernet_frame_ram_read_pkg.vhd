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
    function get_ram_data ( ram_read_port_data_out : ram_read_output_group)
        return std_logic_vector;
------------------------------------------------------------------------
    function ram_data_is_ready ( ram_read_port_data_out : ram_read_output_group)
        return boolean;
------------------------------------------------------------------------
    procedure load_ram_to_shift_register (
        ram_output : in ram_read_output_group;
        signal ram_shift_register : inout std_logic_vector);


end package ethernet_frame_ram_read_pkg;


package body ethernet_frame_ram_read_pkg is
------------------------------------------------------------------------
    procedure init_ram_read
    (
        signal ram_read_port : out ram_read_control_group
    ) is
    begin
        ram_read_port.read_is_enabled_when_1 <= '0'; 
        ram_read_port.address <= (others => '0');
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
    function get_ram_data
    (
        ram_read_port_data_out : ram_read_output_group
    )
    return std_logic_vector 
    is
    begin
        return ram_read_port_data_out.byte_from_ram;
    end get_ram_data;
------------------------------------------------------------------------
    function ram_data_is_ready
    (
        ram_read_port_data_out : ram_read_output_group
    )
    return boolean
    is
    begin
        return ram_read_port_data_out.data_is_ready;
        
    end ram_data_is_ready;
------------------------------------------------------------------------
    procedure load_ram_to_shift_register
    (
        ram_output : in ram_read_output_group;
        signal ram_shift_register : inout std_logic_vector
    ) is
    begin
        if ram_data_is_ready(ram_output) then
            ram_shift_register <= get_ram_data(ram_output) & ram_shift_register(ram_shift_register'left downto 8); 
        end if;

    end load_ram_to_shift_register;

end package body ethernet_frame_ram_read_pkg;

