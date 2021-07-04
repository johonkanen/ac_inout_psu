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

architecture cl10_tx_ddio of ethernet_tx_ddio is

    alias ddio_tx_clock is ethernet_tx_ddio_clocks.core_clock;
    alias ddio_fpga_out is ethernet_tx_ddio_fpga_out.ethernet_tx_ddio_FPGA_io;
    alias data_out_from_fpga is ethernet_tx_ddio_data_in.ethernet_tx_byte;

    component ethddio_tx IS
        PORT
        (
            datain_h : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            datain_l : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            outclock : IN STD_LOGIC ;
            dataout  : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
        );
    END component;

    signal ddio_data_out_h : std_logic_vector(4 downto 0);
    signal ddio_data_out_l : std_logic_vector(4 downto 0);

------------------------------------------------------------------------
begin

    ddio_data_out_h <= ethernet_tx_ddio_data_in.ethernet_tx_ctl   & data_out_from_fpga(7 downto 4);
    ddio_data_out_l <= ethernet_tx_ddio_data_in.ethernet_tx_error & data_out_from_fpga(3 downto 0);
------------------------------------------------------------------------
    u_ethddio : ethddio_tx
        PORT map(
            ddio_data_out_h, 
            ddio_data_out_l, 
            ddio_tx_clock,
            ddio_fpga_out
        );

------------------------------------------------------------------------
end cl10_tx_ddio;
