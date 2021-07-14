library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package ethernet_frame_ram_pkg is

    type ethernet_frame_ram_clock_group is record
        write_clock : std_logic;
        read_clock : std_logic;
    end record;
    
------------------------------------------------------------------------
        type ram_read_control_group is record
            address : std_logic_vector(10 downto 0);
            read_is_enabled_when_1 : std_logic;
        end record;

------------------------------------------------------------------------
        type ram_write_control_group is record
            address              : std_logic_vector(10 downto 0);
            byte_to_write        : std_logic_vector(7 downto 0);
            write_enabled_when_1 : std_logic;
        end record; 
    
------------------------------------------------------------------------
------------------------------------------------------------------------
    type ethernet_frame_ram_data_input_group is record
        ram_write_control_port : ram_write_control_group;
        ram_read_control_port  : ram_read_control_group;
    end record;
    
    type ethernet_frame_ram_data_output_group is record
        data_is_ready : boolean;
        byte_from_ram : std_logic_vector(7 downto 0);
    end record;
    
    component ethernet_frame_ram is
        port (
            ethernet_frame_ram_clocks   : in ethernet_frame_ram_clock_group;
            ethernet_frame_ram_data_in  : in ethernet_frame_ram_data_input_group;
            ethernet_frame_ram_data_out : out ethernet_frame_ram_data_output_group
        );
    end component ethernet_frame_ram;


    -- signal ethernet_frame_ram_clocks   : ethernet_frame_ram_clock_group;
    -- signal ethernet_frame_ram_data_in  : ethernet_frame_ram_data_input_group;
    -- signal ethernet_frame_ram_data_out : ethernet_frame_ram_data_output_group
    
    -- u_ethernet_frame_ram : ethernet_frame_ram
    -- port map( ethernet_frame_ram_clocks,
    --	  ethernet_frame_ram_data_in,
    --	  ethernet_frame_ram_data_out);

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
    

end package ethernet_frame_ram_pkg;


package body ethernet_frame_ram_pkg is

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
end package body ethernet_frame_ram_pkg; 
