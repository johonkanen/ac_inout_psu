library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_pkg.all;

package mdio_driver_internal_pkg is

    constant MDIO_write_command        : std_logic_vector(5 downto 0) := "110101";
    constant MDIO_write_data_delimiter : std_logic_vector(1 downto 0) := "10";
    constant MDIO_read_command         : std_logic_vector(5 downto 0) := "110110";

    constant mdio_clock_divisor_counter_high : integer := 4;
    constant mdio_transmit_counter_high : integer := (mdio_clock_divisor_counter_high+1)*33;

    type mdio_transmit_control_group is record
        mdio_transmit_register          : std_logic_vector(33 downto 0);
        mdio_data_receive_register      : std_logic_vector(15 downto 0);
        mdio_clock                      : std_logic;
        mdio_clock_counter              : natural range 0 to 15;
        MDIO_io_direction_is_out_when_1 : std_logic;
        mdio_transmit_clock             : natural range 0 to 511;
        mdio_receive_clock              : natural range 0 to 511;
        mdio_transmit_is_ready          : boolean;
        mdio_receive_is_ready           : boolean;
    end record; 
    constant mdio_transmit_control_init : mdio_transmit_control_group := ((others=>'0') , (others => '0'), '0' , 0 , '0' , 0, 0, false, false);

--------------------------------------------------
    procedure generate_mdio_io_waveforms (
        signal mdio_transmit : inout mdio_transmit_control_group);
--------------------------------------------------
    procedure load_data_to_mdio_transmit_shift_register (
        signal mdio_control : out mdio_transmit_control_group;
        data : std_logic_vector );
--------------------------------------------------
    procedure write_data_with_mdio (
        mdio_input : in mdio_driver_data_input_group;
        signal mdio_control : out mdio_transmit_control_group);

end package mdio_driver_internal_pkg;

package body mdio_driver_internal_pkg is

--------------------------------------------------
    procedure generate_mdio_io_waveforms
    (
        signal mdio_transmit : inout mdio_transmit_control_group
    ) is
    begin

        mdio_transmit.mdio_clock_counter <= mdio_transmit.mdio_clock_counter + 1;
        if mdio_transmit.mdio_clock_counter = mdio_clock_divisor_counter_high then 
            mdio_transmit.mdio_clock_counter <= 0;
        end if;

        mdio_transmit.mdio_clock <= '1';
        if mdio_transmit.mdio_clock_counter > mdio_clock_divisor_counter_high/2-1 then
            mdio_transmit.mdio_clock <= '0'; 
        end if; 

        if mdio_transmit.mdio_clock_counter = mdio_clock_divisor_counter_high/2-2 then
            mdio_transmit.mdio_transmit_register <= mdio_transmit.mdio_transmit_register(mdio_transmit.mdio_transmit_register'left-1 downto 0) & '0';
        end if;

        if mdio_transmit.mdio_transmit_clock /= 0 then
            mdio_transmit.mdio_transmit_clock <= mdio_transmit.mdio_transmit_clock - 1;
        end if;

        mdio_transmit.mdio_transmit_is_ready <= false;
        if mdio_transmit.mdio_transmit_clock = 1 then
            mdio_transmit.mdio_transmit_is_ready <= true;
        end if;
        
    end generate_mdio_io_waveforms;

--------------------------------------------------
    procedure load_data_to_mdio_transmit_shift_register
    (
        signal mdio_control : out mdio_transmit_control_group;
        data : std_logic_vector
        
    ) is
    begin
        mdio_control.mdio_transmit_register(mdio_control.mdio_transmit_register'left downto mdio_control.mdio_transmit_register'left-data'high) <= data;
        
    end load_data_to_mdio_transmit_shift_register;

--------------------------------------------------
    procedure write_data_with_mdio
    (
        mdio_input : in mdio_driver_data_input_group;
        signal mdio_control : out mdio_transmit_control_group
    ) is
    begin
        if mdio_input.mdio_data_write_is_requested then
            load_data_to_mdio_transmit_shift_register(mdio_control, 
                                MDIO_write_command                          &
                                mdio_input.phy_address(4 downto 0)          &
                                mdio_input.phy_register_address(4 downto 0) &
                                "10"                                        &
                                mdio_input.data_to_mdio(15 downto 0));
            mdio_control.mdio_transmit_clock <= mdio_transmit_counter_high;
        end if;

    end write_data_with_mdio;
--------------------------------------------------
    procedure read_data_with_mdio
    (
        mdio_input : in mdio_driver_data_input_group;
        signal mdio_control : out mdio_transmit_control_group
    ) is
    begin
        if mdio_input.mdio_data_read_is_requested then
            load_data_to_mdio_transmit_shift_register(mdio_control, 
                                MDIO_write_command                          &
                                mdio_input.phy_address(4 downto 0)          &
                                mdio_input.phy_register_address(4 downto 0) &
                                "10"                                        &
                                mdio_input.data_to_mdio(15 downto 0));
            mdio_control.mdio_transmit_clock <= mdio_transmit_counter_high - 15;
        end if;
        
    end read_data_with_mdio;

--------------------------------------------------
end package body mdio_driver_internal_pkg;

