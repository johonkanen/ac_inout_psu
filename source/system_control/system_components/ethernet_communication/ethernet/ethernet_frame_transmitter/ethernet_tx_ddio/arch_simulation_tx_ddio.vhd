library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_tx_ddio_pkg.all;

-- entity ethernet_tx_ddio is
--     port (
--         ethernet_tx_ddio_clocks   : in ethernet_tx_ddio_pkg_clock_group;
--         ethernet_tx_ddio_FPGA_out : out ethernet_tx_ddio_pkg_FPGA_output_group;
--         ethernet_tx_ddio_data_in  : in ethernet_tx_ddio_pkg_data_input_group
--     );
-- end entity;

architecture simulation of ethernet_tx_ddio is

    alias ddio_tx_clock is ethernet_tx_ddio_clocks.core_clock;
    alias ddio_fpga_out is ethernet_tx_ddio_fpga_out.ethernet_tx_ddio_FPGA_io;
    alias data_out_from_fpga is ethernet_tx_ddio_data_in.ethernet_tx_byte;

begin

    ddio_driver_simulation : process(ddio_tx_clock)
        
    begin
        if rising_edge(ddio_tx_clock) then
            ddio_fpga_out(3) <= data_out_from_fpga(3);
            ddio_fpga_out(2) <= data_out_from_fpga(2);
            ddio_fpga_out(1) <= data_out_from_fpga(1);
            ddio_fpga_out(0) <= data_out_from_fpga(0);
            -- ethernet_tx_ddio_FPGA_out.ethernet_tx_ctl <= ethernet_tx_ddio_data_in.ethernet_frame_enable;
        end if; --rising_edge

        if falling_edge(ddio_tx_clock) then
            ddio_fpga_out(3) <= data_out_from_fpga(7);
            ddio_fpga_out(2) <= data_out_from_fpga(6);
            ddio_fpga_out(1) <= data_out_from_fpga(5);
            ddio_fpga_out(0) <= data_out_from_fpga(4);
            -- ethernet_tx_ddio_FPGA_out.ethernet_tx_ctl <= ethernet_tx_ddio_data_in.ethernet_tx_error;
        end if; --falling_edge

    end process ddio_driver_simulation;	
end simulation;
