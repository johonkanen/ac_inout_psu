library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package mdio_driver_pkg is

    type mdio_driver_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type mdio_driver_FPGA_input_group is record
        MDIO_serial_data_in : std_logic;
    end record;
    
    type mdio_driver_FPGA_output_group is record
        MDIO_serial_data_out       : std_logic;
        MDIO_io_direction_1_output : std_logic;
        mdio_clock                 : std_logic;
    end record;
    
    type mdio_driver_data_input_group is record
        mdio_data_read_is_requested  : boolean;
        mdio_data_write_is_requested : boolean;
        data_to_mdio                 : std_logic_vector(15 downto 0);
        phy_address                  : std_logic_vector(7 downto 0);
        phy_register_address         : std_logic_vector(7 downto 0);
    end record;
    
    type mdio_driver_data_output_group is record
        mdio_driver_is_ready : boolean;
        data_from_mdio       : std_logic_vector(15 downto 0);
    end record;
    
    component mdio_driver is
        port (
            mdio_driver_clocks : in mdio_driver_clock_group;
    
            mdio_driver_FPGA_in : in mdio_driver_FPGA_input_group;
            mdio_driver_FPGA_out : out mdio_driver_FPGA_output_group;
    
            mdio_driver_data_in : in mdio_driver_data_input_group;
            mdio_driver_data_out : out mdio_driver_data_output_group
        );
    end component mdio_driver;

----------------------------------------------------------------
    procedure init_mdio_driver ( signal mdio_input : out mdio_driver_data_input_group);

----------------------------------------------------------------
    function get_data_from_mdio ( mdio_output : in mdio_driver_data_output_group)
        return std_logic_vector;

----------------------------------------------------------------
    function mdio_is_ready ( mdio_output : mdio_driver_data_output_group)
        return boolean;
----------------------------------------------------------------
    procedure read_data_from_mdio (
        signal mdio_input    : out mdio_driver_data_input_group;
        phy_address          : std_logic_vector(7 downto 0);
        phy_register_address : std_logic_vector(7 downto 0));
----------------------------------------------------------------
    procedure write_data_to_mdio (
        signal mdio_input : out mdio_driver_data_input_group;
        phy_address       : std_logic_vector(7 downto 0);
        register_address  : std_logic_vector(7 downto 0);
        data_to_mdio      : in std_logic_vector(15 downto 0));
        
end package mdio_driver_pkg;

-- signal mdio_driver_clocks   : mdio_driver_clock_group;
-- signal mdio_driver_FPGA_in  : mdio_driver_FPGA_input_group;
-- signal mdio_driver_FPGA_out : mdio_driver_FPGA_output_group;
-- signal mdio_driver_data_in  : mdio_driver_data_input_group;
-- signal mdio_driver_data_out  : mdio_driver_data_output_group;

-- u_mdio_driver : mdio_driver
-- port map(
--     mdio_driver_clocks,
--     mdio_driver_FPGA_in, -- route out of fpga
--     mdio_driver_FPGA_out,
--     mdio_driver_data_in, 
--     mdio_driver_data_out);

package body mdio_driver_pkg is

    function get_data_from_mdio
    (
        mdio_output : in mdio_driver_data_output_group
    ) return std_logic_vector
    is
    begin
        return mdio_output.data_from_mdio;
        
    end get_data_from_mdio;

--------------------------------------------------------------------
    function mdio_is_ready
    (
        mdio_output : mdio_driver_data_output_group
    )
    return boolean
    is
    begin
        return mdio_output.mdio_driver_is_ready;
        
    end mdio_is_ready;

--------------------------------------------------------------------
    procedure init_mdio_driver
    (
        signal mdio_input : out mdio_driver_data_input_group
    ) is
    begin
        mdio_input.mdio_data_read_is_requested  <= false;
        mdio_input.mdio_data_write_is_requested <= false;
    end init_mdio_driver;

--------------------------------------------------------------------
    procedure read_data_from_mdio
    (
        signal mdio_input : out mdio_driver_data_input_group;
        phy_address : std_logic_vector(7 downto 0);
        phy_register_address : std_logic_vector(7 downto 0)
    ) is
    begin
        mdio_input.mdio_data_read_is_requested <= true;
        mdio_input.phy_address                 <= phy_address;
        mdio_input.phy_register_address        <= phy_register_address;
    end read_data_from_mdio;

--------------------------------------------------------------------
    procedure write_data_to_mdio
    (
        signal mdio_input : out mdio_driver_data_input_group;
        phy_address : std_logic_vector(7 downto 0);
        register_address : std_logic_vector(7 downto 0);
        data_to_mdio : in std_logic_vector(15 downto 0)
    ) is
    begin
        mdio_input.mdio_data_write_is_requested <= true;
        mdio_input.mdio_data_read_is_requested  <= true;
        mdio_input.phy_address                  <= phy_address;
        mdio_input.phy_register_address         <= register_address;
        mdio_input.data_to_mdio                 <= data_to_mdio;
    end write_data_to_mdio;

end package body mdio_driver_pkg;
