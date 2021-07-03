library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;

package ethernet_rx_ddio_pkg is

------------------------------------------------------------------------
    type ethernet_rx_ddio_FPGA_input_group is record
        rx_ctl : std_logic;
        ethernet_rx_ddio_in : std_logic_vector(3 downto 0);
    end record;
    
------------------------------------------------------------------------
    type ethernet_rx_ddio_data_output_group is record
        rx_ctl : std_logic;
        ethernet_rx_byte : std_logic_vector(7 downto 0);
    end record;
    
------------------------------------------------------------------------
    component ethernet_rx_ddio is
        port (
            ethernet_rx_ddio_clocks   : in ethernet_clock_group;
            ethernet_rx_ddio_FPGA_in  : in ethernet_rx_ddio_FPGA_input_group;
            ethernet_rx_ddio_data_out : out ethernet_rx_ddio_data_output_group
        );
    end component ethernet_rx_ddio;

------------------------------------------------------------------------
    function get_byte ( ethernet_rx_output : ethernet_rx_ddio_data_output_group)
        return std_logic_vector;

    function ethernet_rx_active ( ethernet_rx_ddr_output : ethernet_rx_ddio_data_output_group)
        return boolean;
------------------------------------------------------------------------
end package ethernet_rx_ddio_pkg;

    -- signal ethernet_rx_ddio_clocks   : ethernet_rx_ddio_clock_group;
    -- signal ethernet_rx_ddio_FPGA_out : ethernet_rx_ddio_FPGA_output_group;
    -- signal ethernet_rx_ddio_data_in  : ethernet_rx_ddio_data_output_group;
    
    -- u_ethernet_rx_ddio_pkg : ethernet_rx_ddio_pkg
    -- port map( ethernet_rx_ddio_clocks,
    --	  ethernet_rx_ddio_FPGA_out,
    --	  ethernet_rx_ddio_data_in);

package body ethernet_rx_ddio_pkg is

------------------------------------------------------------------------
    function ethernet_rx_active
    (
        ethernet_rx_ddr_output : ethernet_rx_ddio_data_output_group
    )
    return boolean
    is
    begin
        if ethernet_rx_ddr_output.rx_ctl = '1' then
            return true;
        else
            return false;
        end if;
        
------------------------------------------------------------------------
    end ethernet_rx_active;

    function get_byte
    (
        ethernet_rx_output : ethernet_rx_ddio_data_output_group
    )
    return std_logic_vector 
    is
    begin
        return ethernet_rx_output.ethernet_rx_byte; 
    end get_byte;

------------------------------------------------------------------------
end package body ethernet_rx_ddio_pkg;
