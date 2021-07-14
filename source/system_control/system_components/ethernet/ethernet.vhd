
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

    signal ethernet_frame_transmitter_data_in : ethernet_frame_transmitter_data_input_group;
    signal ethernet_frame_transmitter_data_out : ethernet_frame_transmitter_data_output_group;

    signal ethernet_frame_ram_clocks   : ethernet_frame_ram_clock_group;
    signal ethernet_frame_ram_data_in  : ethernet_frame_ram_data_input_group;
    signal ethernet_frame_ram_data_out : ethernet_frame_ram_data_output_group;

begin 

------------------------------------------------------------------------
    ethernet_data_out <= (mdio_driver_data_out  => mdio_driver_data_out,
                         ethernet_frame_ram_out => ethernet_frame_ram_data_out.ram_read_port_data_out);

------------------------------------------------------------------------

    ethernet_frame_ram_data_in <= (ram_write_control_port => ethernet_frame_receiver_data_out.ram_write_control_port,
                                  ram_read_control_port   => ethernet_data_in.ram_read_control_port); 

    ethernet_frame_ram_clocks <= (read_clock => ethernet_clocks.core_clock, 
                                 write_clock => ethernet_clocks.rx_ddr_clocks.rx_ddr_clock);

    u_ethernet_frame_ram : ethernet_frame_ram
    port map( ethernet_frame_ram_clocks  ,
              ethernet_frame_ram_data_in ,
              ethernet_frame_ram_data_out);
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
