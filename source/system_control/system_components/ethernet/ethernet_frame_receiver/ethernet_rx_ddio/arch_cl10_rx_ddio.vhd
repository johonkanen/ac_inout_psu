library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_rx_ddio_pkg.all;

-- entity ethernet_rx_ddio is
--     port (
--         ethernet_rx_ddio_clocks   : in ethernet_rx_ddio_pkg_clock_group;
--         ethernet_rx_ddio_FPGA_out : out ethernet_rx_ddio_pkg_FPGA_output_group;
--         ethernet_rx_ddio_data_in  : in ethernet_rx_ddio_pkg_data_input_group
--     );
-- end entity;

architecture cl10_rx_ddio of ethernet_rx_ddio is

    alias ddio_rx_clock is ethernet_rx_ddio_clocks.rx_ddr_clock;
    alias ddio_fpga_in is ethernet_rx_ddio_fpga_in.ethernet_rx_ddio_in;
    alias ethernet_byte_to_fpga is ethernet_rx_ddio_data_out.ethernet_rx_byte;

    component ethddio_rx IS
	PORT
	(
		datain    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		inclock   : IN STD_LOGIC ;
		dataout_h : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		dataout_l : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
    END component;

------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    u_ethddio : ethddio_rx
        PORT map(
            ddio_fpga_in,
            ddio_rx_clock,
            ethernet_byte_to_fpga(7 downto 4),
            ethernet_byte_to_fpga(3 downto 0)
        );

------------------------------------------------------------------------
end cl10_rx_ddio;
