library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_pkg.all;

package mdio_mmd_access_control_pkg is

    type mdio_mmd_access_control_clock_group is record
        clock : std_logic;
        reset_n : std_logic;
    end record;
    
    type mdio_mmd_access_control_FPGA_inout_group is record
        mdio_driver_FPGA_inout : mdio_driver_FPGA_three_state_record;
    end record;
    
    type mdio_mmd_access_control_FPGA_output_group is record
        mdio_driver_FPGA_out : mdio_driver_FPGA_output_group;
    end record;
    
    type mdio_mmd_access_control_data_input_group is record
        mdio_driver_data_in : mdio_driver_data_input_group;
        mmd_read_is_requested : boolean;
        mmd_write_is_requested : boolean;
        mmd_address : std_logic_vector(15 downto 0);
        data_to_mmd : std_logic_vector(15 downto 0);
    end record;
    
    type mdio_mmd_access_control_data_output_group is record
        mdio_driver_data_out : mdio_driver_data_output_group;
        data_from_mmd : std_logic_vector(15 downto 0);
        mmd_is_ready : boolean;
    end record;
    
    component mdio_mmd_access_control is
        port (
            mdio_mmd_access_control_clocks     : in mdio_mmd_access_control_clock_group;
            mdio_mmd_access_control_FPGA_out   : out mdio_mmd_access_control_FPGA_output_group;
            mdio_mmd_access_control_FPGA_inout : inout mdio_mmd_access_control_FPGA_inout_group;
            mdio_mmd_access_control_data_in    : in mdio_mmd_access_control_data_input_group;
            mdio_mmd_access_control_data_out   : out mdio_mmd_access_control_data_output_group
        );
    end component mdio_mmd_access_control;
    
    -- signal mdio_mmd_access_control_clocks   : mdio_mmd_access_control_clock_group;
    -- signal mdio_mmd_access_control_data_in  : mdio_mmd_access_control_data_input_group;
    -- signal mdio_mmd_access_control_data_out : mdio_mmd_access_control_data_output_group
    
    -- u_mdio_mmd_access_control : mdio_mmd_access_control
    -- port map( mdio_mmd_access_control_clocks,
    -- 	  mdio_mmd_access_control_FPGA_in,
    --	  mdio_mmd_access_control_FPGA_out,
    --	  mdio_mmd_access_control_data_in,
    --	  mdio_mmd_access_control_data_out);

------------------------------------------------------------------------
    procedure enable_ethernet_physical_control (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group);

------------------------------------------------------------------------
    procedure read_mmd_register (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group;
        mmd_address : std_logic_vector(7 downto 0));
------------------------------------------------------------------------
    procedure write_mmd_register (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group;
        mmd_address : std_logic_vector(7 downto 0);
        data_to_mmd : std_logic_vector(15 downto 0));

------------------------------------------------------------------------
    function mmd_is_ready ( ethernet_physical_control_output : mdio_mmd_access_control_data_output_group)
        return boolean;

------------------------------------------------------------------------
end package mdio_mmd_access_control_pkg;

package body mdio_mmd_access_control_pkg is

------------------------------------------------------------------------
    procedure enable_ethernet_physical_control
    (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group
    ) is
    begin
        ethernet_physical_control_input.mmd_read_is_requested <= false;
        ethernet_physical_control_input.mmd_write_is_requested <= false;

    end enable_ethernet_physical_control;

------------------------------------------------------------------------
    procedure read_mmd_register
    (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group;
        mmd_address : std_logic_vector(7 downto 0)
    ) is
    begin
        ethernet_physical_control_input.mmd_read_is_requested <= true;
        ethernet_physical_control_input.mmd_address(15 downto 8) <= mmd_address;
        
    end read_mmd_register;

------------------------------------------------------------------------
    procedure write_mmd_register
    (
        signal ethernet_physical_control_input : out mdio_mmd_access_control_data_input_group;
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
        ethernet_physical_control_output : mdio_mmd_access_control_data_output_group
    )
    return boolean
    is
    begin
        return ethernet_physical_control_output.mmd_is_ready;

    end mmd_is_ready;

------------------------------------------------------------------------
    function get_mmd_data
    (
        ethernet_physical_control_output : mdio_mmd_access_control_data_output_group
    )
    return std_logic_vector
    is
    begin
        return ethernet_physical_control_output.data_from_mmd;
        
    end get_mmd_data;

------------------------------------------------------------------------
end package body mdio_mmd_access_control_pkg;

