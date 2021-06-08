library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_pkg.all;

package mdio_interface_pkg is

    type mdio_interface_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type mdio_interface_FPGA_input_group is record
        mdio_driver_FPGA_in : mdio_driver_FPGA_input_group;
    end record;
    
    type mdio_interface_FPGA_output_group is record
        mdio_driver_FPGA_out : mdio_driver_FPGA_output_group;
    end record;
    
    type mdio_interface_data_input_group is record
        mdio_driver_data_in : mdio_driver_data_input_group;
        mmd_read_is_requested : boolean;
        mmd_write_is_requested : boolean;
        mmd_address : std_logic_vector(15 downto 0);
        data_to_mmd : std_logic_vector(15 downto 0);
    end record;
    
    type mdio_interface_data_output_group is record
        mdio_driver_data_out : mdio_driver_data_output_group;
        data_from_mmd : std_logic_vector(15 downto 0);
        mmd_is_ready : boolean;
    end record;
    
    component mdio_interface is
        port (
            mdio_interface_clocks   : in mdio_interface_clock_group;
            mdio_interface_FPGA_in  : in mdio_interface_FPGA_input_group;
            mdio_interface_FPGA_out : out mdio_interface_FPGA_output_group;
            mdio_interface_data_in  : in mdio_interface_data_input_group;
            mdio_interface_data_out : out mdio_interface_data_output_group
        );
    end component mdio_interface;
    
    -- signal mdio_interface_clocks   : mdio_interface_clock_group;
    -- signal mdio_interface_data_in  : mdio_interface_data_input_group;
    -- signal mdio_interface_data_out : mdio_interface_data_output_group
    
    -- u_mdio_interface : mdio_interface
    -- port map( mdio_interface_clocks,
    -- 	  mdio_interface_FPGA_in,
    --	  mdio_interface_FPGA_out,
    --	  mdio_interface_data_in,
    --	  mdio_interface_data_out);

------------------------------------------------------------------------
    procedure enable_ethernet_physical_control (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group);

------------------------------------------------------------------------
    procedure read_mmd_register (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group;
        mmd_address : std_logic_vector(7 downto 0));
------------------------------------------------------------------------
    procedure write_mmd_register (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group;
        mmd_address : std_logic_vector(7 downto 0);
        data_to_mmd : std_logic_vector(15 downto 0));

------------------------------------------------------------------------
    function mmd_is_ready ( ethernet_physical_control_output : mdio_interface_data_output_group)
        return boolean;

------------------------------------------------------------------------
end package mdio_interface_pkg;

package body mdio_interface_pkg is

------------------------------------------------------------------------
    procedure enable_ethernet_physical_control
    (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group
    ) is
    begin
        ethernet_physical_control_input.mmd_read_is_requested <= false;
        ethernet_physical_control_input.mmd_write_is_requested <= false;

    end enable_ethernet_physical_control;

------------------------------------------------------------------------
    procedure read_mmd_register
    (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group;
        mmd_address : std_logic_vector(7 downto 0)
    ) is
    begin
        ethernet_physical_control_input.mmd_read_is_requested <= true;
        ethernet_physical_control_input.mmd_address(15 downto 8) <= mmd_address;
        
    end read_mmd_register;

------------------------------------------------------------------------
    procedure write_mmd_register
    (
        signal ethernet_physical_control_input : out mdio_interface_data_input_group;
        mmd_address : std_logic_vector(7 downto 0);
        data_to_mmd : std_logic_vector(15 downto 0)
    ) is
    begin
        ethernet_physical_control_input.mmd_write_is_requested <= true;
        ethernet_physical_control_input.mmd_address(15 downto 8) <= mmd_address;
        ethernet_physical_control_input.data_to_mmd <= data_to_mmd;
        
    end write_mmd_register;

------------------------------------------------------------------------
    function mmd_is_ready
    (
        ethernet_physical_control_output : mdio_interface_data_output_group
    )
    return boolean
    is
    begin
        return ethernet_physical_control_output.mmd_is_ready;

    end mmd_is_ready;

------------------------------------------------------------------------
    function get_mmd_data
    (
        ethernet_physical_control_output : mdio_interface_data_output_group
    )
    return std_logic_vector
    is
    begin
        return ethernet_physical_control_output.data_from_mmd;
        
    end get_mmd_data;

------------------------------------------------------------------------
end package body mdio_interface_pkg;

