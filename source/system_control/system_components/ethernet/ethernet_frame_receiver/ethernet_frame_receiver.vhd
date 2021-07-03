library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_rx_ddio_pkg.all; 

entity ethernet_frame_receiver is
    port (
        ethernet_frame_receiver_clocks  : in ethernet_rx_ddr_clock_group;
        ethernet_frame_receiver_FPGA_in : in ethernet_frame_receiver_FPGA_input_group;
        ethernet_frame_receiver_data_in : in ethernet_frame_receiver_data_input_group;
        ethernet_frame_receiver_data_out : out ethernet_frame_receiver_data_output_group
    );
end entity ethernet_frame_receiver;

architecture rtl of ethernet_frame_receiver is

    signal ethernet_rx_ddio_data_out  : ethernet_rx_ddio_data_output_group;

    alias rx_ddr_clock is ethernet_frame_receiver_clocks.rx_ddr_clock;

    type bytearray is array (integer range <>) of std_logic_vector(7 downto 0); 
    signal stuff : bytearray(0 to 46);

    signal rx_shift_register : std_logic_vector(15 downto 0) := (others => '0');

    signal test_data : std_logic_vector(7 downto 0) := (others => '0');

    
begin

    ethernet_frame_receiver_data_out <= (test_data => test_data);

    frame_receiver : process(rx_ddr_clock) 
    begin
        if rising_edge(rx_ddr_clock) then 

            if ethernet_rx_active(ethernet_rx_ddio_data_out) then
                rx_shift_register <= rx_shift_register(7 downto 0) & get_byte(ethernet_rx_ddio_data_out); 
                if rx_shift_register /= x"0000" then
                    test_data <= rx_shift_register(7 downto 0);
                end if;
            end if; 

        end if; --rising_edge
    end process frame_receiver;	

------------------------------------------------------------------------
    u_ethernet_rx_ddio : ethernet_rx_ddio
    port map( ethernet_frame_receiver_clocks                           ,
              ethernet_frame_receiver_FPGA_in.ethernet_rx_ddio_FPGA_in ,
              ethernet_rx_ddio_data_out);

------------------------------------------------------------------------
end rtl;
