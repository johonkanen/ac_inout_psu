
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_pkg.all;
    use work.mdio_driver_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_frame_transmitter_pkg.all;
    use work.ethernet_frame_ram_pkg.all;
    use work.ethernet_frame_ram_read_pkg.all;
    use work.ethernet_protocol_pkg.all;

entity ethernet is
    port (
        ethernet_clocks     : in ethernet_clock_group;
        ethernet_FPGA_in    : in ethernet_FPGA_input_group;
        ethernet_FPGA_out   : out ethernet_FPGA_output_group;
        ethernet_FPGA_inout : inout ethernet_FPGA_inout_record;
        ethernet_data_in    : in ethernet_data_input_group;
        ethernet_data_out   : out ethernet_data_output_group
    );
end entity;

architecture rtl of ethernet is

--------------------------------------------------
    signal mdio_driver_clocks : mdio_driver_clock_group;
    signal mdio_driver_data_out : mdio_driver_data_output_group;

    signal ethernet_frame_receiver_data_out : ethernet_frame_receiver_data_output_group;

    signal ethernet_frame_transmitter_data_in  : ethernet_frame_transmitter_data_input_group;
    signal ethernet_frame_transmitter_data_out : ethernet_frame_transmitter_data_output_group;

    signal ethernet_frame_ram_clocks   : ethernet_frame_ram_clock_group;
    signal ethernet_frame_ram_data_in  : ethernet_frame_ram_data_input_group;
    signal ethernet_frame_ram_data_out : ethernet_frame_ram_data_output_group;

    signal ethernet_protocol_clocks   : ethernet_protocol_clock_group;
    signal ethernet_protocol_data_in  : ethernet_protocol_data_input_group;
    signal ethernet_protocol_data_out : ethernet_protocol_data_output_group;

    signal frame_ram_read_control_port : ram_read_control_group;

    signal frame_is_received : boolean;

    signal shift_register : std_logic_vector(2 downto 0);
------------------------------------------------------------------------ 

begin 

------------------------------------------------------------------------
    ethernet_data_out <= (mdio_driver_data_out      => mdio_driver_data_out,
                         ethernet_frame_ram_out     => ethernet_frame_ram_data_out.ram_read_port_data_out,
                         ethernet_protocol_data_out => ethernet_protocol_data_out);

------------------------------------------------------------------------
    ram_read_bus : process(ethernet_data_in.ram_read_control_port, ethernet_protocol_data_out.frame_ram_read_control)
        
    begin

        frame_ram_read_control_port <= ethernet_data_in.ram_read_control_port +
                                       ethernet_protocol_data_out.frame_ram_read_control;
    end process ram_read_bus;	

------------------------------------------------------------------------
------------------------------------------------------------------------

    ethernet_frame_ram_data_in <= (ram_write_control_port => ethernet_frame_receiver_data_out.ram_write_control_port,
                                  ram_read_control_port   => frame_ram_read_control_port); 

    ethernet_frame_ram_clocks <= (read_clock => ethernet_clocks.core_clock, 
                                 write_clock => ethernet_clocks.rx_ddr_clocks.rx_ddr_clock);

    u_ethernet_frame_ram : ethernet_frame_ram
    port map( ethernet_frame_ram_clocks  ,
              ethernet_frame_ram_data_in ,
              ethernet_frame_ram_data_out);
------------------------------------------------------------------------ 
------------------------------------------------------------------------ 

    u_ethernet_frame_receiver : ethernet_frame_receiver
    port map( ethernet_clocks.rx_ddr_clocks                    ,
              ethernet_FPGA_in.ethernet_frame_receiver_FPGA_in ,
              ethernet_frame_receiver_data_out); 

------------------------------------------------------------------------ 
    u_ethernet_frame_transmitter : ethernet_frame_transmitter
    port map( ethernet_clocks.tx_ddr_clocks                         ,
              ethernet_FPGA_out.ethernet_frame_transmitter_FPGA_out ,
              ethernet_frame_transmitter_data_in                    ,
              ethernet_frame_transmitter_data_out);

------------------------------------------------------------------------ 

    protocol_trigger : process(ethernet_clocks.core_clock)
        
    begin
        if rising_edge(ethernet_clocks.core_clock) then
            shift_register <= shift_register(shift_register'left-1 downto 0 ) & ethernet_frame_receiver_data_out.toggle_data_has_been_written;

            frame_is_received <= shift_register(shift_register'left) = '0' AND shift_register(shift_register'left-1) = '1';

        end if; --rising_edge
    end process protocol_trigger;	
------------------------------------------------------------------------ 
    ethernet_protocol_clocks <= (clock => ethernet_clocks.core_clock);

    ethernet_protocol_data_in <= (frame_ram_output        => ethernet_frame_ram_data_out.ram_read_port_data_out,
                                 protocol_processing_is_requested => frame_is_received); -- ethernet_frame_receiver_data_out.toggle_data_has_been_written);
                                   

    u_ethernet_protocol : ethernet_protocol
    port map( ethernet_protocol_clocks,
    	  ethernet_protocol_data_in,
    	  ethernet_protocol_data_out);

------------------------------------------------------------------------ 
------------------------------------------------------------------------ 
    mdio_driver_clocks <= (clock => ethernet_clocks.core_clock);
    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        ethernet_FPGA_out.mdio_driver_FPGA_out ,
        ethernet_FPGA_inout.mdio_driver_FPGA_inout ,
        ethernet_data_in.mdio_driver_data_in  ,
        mdio_driver_data_out); 

------------------------------------------------------------------------
end rtl;
