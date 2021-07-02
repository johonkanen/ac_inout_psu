library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_pkg.all;

package ethernet_pkg is

    type ethernet_clock_group is record
        core_clock : std_logic;
    end record;
    
    type ethernet_FPGA_input_group is record
        data : std_logic; 
    end record;
    
    type ethernet_FPGA_output_group is record
        mdio_driver_FPGA_out : mdio_driver_FPGA_output_group; 
    end record;

    type ethernet_FPGA_inout_record is record
        mdio_driver_FPGA_inout : mdio_driver_FPGA_three_state_record;
    end record;
    
    type ethernet_data_input_group is record
        mdio_driver_data_in : mdio_driver_data_input_group;
    end record;
    
    type ethernet_data_output_group is record
        mdio_driver_data_out : mdio_driver_data_output_group;
    end record;
    
    component ethernet is
        port (
            ethernet_clocks     : in ethernet_clock_group;
            ethernet_FPGA_in    : in ethernet_FPGA_input_group;
            ethernet_FPGA_out   : out ethernet_FPGA_output_group;
            ethernet_FPGA_inout : inout ethernet_FPGA_inout_record;
            ethernet_data_in    : in ethernet_data_input_group;
            ethernet_data_out   : out ethernet_data_output_group
        );
    end component ethernet;
    
    -- signal ethernet_clocks     : ethernet_clock_group;
    -- signal ethernet_FPGA_in    : ethernet_FPGA_input_group;
    -- signal ethernet_FPGA_out   : ethernet_FPGA_output_group;
    -- signal ethernet_FPGA_inout : ethernet_FPGA_inout_record;
    -- signal ethernet_data_in    : ethernet_data_input_group;
    -- signal ethernet_data_out   : ethernet_data_output_group
    
    -- u_ethernet : ethernet
    -- port map( ethernet_clocks ,
    -- 	  ethernet_FPGA_in       ,
    --	  ethernet_FPGA_out      ,
    --    ethernet_FPGA_inout    ,
    --	  ethernet_data_in       ,
    --	  ethernet_data_out);
    

end package ethernet_pkg;
