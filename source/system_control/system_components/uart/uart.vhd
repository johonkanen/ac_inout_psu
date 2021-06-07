library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;

entity uart is
    port (
        uart_clocks   : in uart_clock_group;
        uart_FPGA_in  : in uart_FPGA_input_group;
        uart_FPGA_out : out uart_FPGA_output_group;
        uart_data_in  : in uart_data_input_group;
        uart_data_out : out uart_data_output_group
    );
end entity uart;

architecture rtl of uart is

    alias uart_clk is uart_clocks.clock;

    alias pi_uart_rx_serial is uart_FPGA_in.uart_rx;
    alias po_uart_tx_serial is uart_FPGA_out.uart_tx;

    alias si_uart_start_event is uart_data_in.uart_is_started_with_1;
    alias si16_uart_tx_data   is uart_data_in.uart_tx_data;
    alias so16_uart_rx_data   is uart_data_out.uart_rx_data;
    alias so_uart_rx_rdy      is uart_data_out.uart_rx_ready_when_1;

	signal r_rx_data_out		: std_logic_vector(15 downto 0);
	alias rx_uart_cmd_offset	: std_logic_vector(3 downto 0) is r_rx_data_out(15 downto 12);
	alias rx_uart_cmd_data		: std_logic_vector(11 downto 0) is r_rx_data_out(11 downto 0);
	 
	type st_uart_stream is (idle, 
							ack, 
							latch, 
							ready); 
	
	signal r15_uart_data_in		: std_logic_vector(15 downto 0); 
	signal route_uart_tx_data	: std_logic_vector(15 downto 0); 
	 
	signal r_uart_start_event : std_logic; 
	 
	signal route_uart_tx_active : std_logic;
	signal route_uart_tx_done : std_logic; 
	signal r_rx_ready_event : std_logic; 
	 
	signal route_uart_tx_start : std_logic; 
	 
	type uart_states is (idle, 
						ack, 
						latch, 
						ready); 
						 
	signal r_pres_state, r_next_state : uart_states; 
	 
begin

    uart1 : entity work.uart_transreceiver
	generic map(
				g_CLKS_PER_BIT => CLKS_PER_BIT,
				g_RX_bytes_in_word => RX_bytes_in_word,
				g_TX_bytes_in_word => TX_bytes_in_word
			)
				
	port map(
			uart_Clk   		=> uart_Clk,
			
			i_TX_start     	=> route_uart_tx_start,
			i_TX_data_in    => route_uart_tx_data,
			
			so_uart_tx_active => route_uart_tx_active,
			uart_tx_done   	=> route_uart_tx_done, 
			
			uart_tx_serial 	=> po_uart_tx_serial,
			uart_rx_serial 	=> pi_uart_rx_serial, 
			
			rx_ready_event	=> r_rx_ready_event, 
			o_RX_data_out  	=> r_rx_data_out
			
		);

---------------------------------------------

	
r_pres_state <=r_next_state;

	uart_control : process(uart_Clk,r_pres_state,route_uart_tx_active, r_pres_state)
	begin
	if rising_edge(uart_Clk) then 
		CASE r_next_state is 
			WHEN idle =>  
				route_uart_tx_start <= '0'; 
				if si_uart_start_event = '1' then 
					r15_uart_data_in <= si16_uart_tx_data; 
					r_next_state <= ack; 
				else 
					r_next_state <= idle; 
				end if; 
			WHEN ack => 
 
				if route_uart_tx_active = '0' then 
					r_next_state <= latch; 
					route_uart_tx_start <= '1'; 
				else  
					r_next_state <= ack; 
					route_uart_tx_start <= '0'; 
				end if; 
			WHEN latch =>  
 
				if route_uart_tx_active = '1' then 
					r_next_state <= ready; 
					route_uart_tx_start <= '0'; 
				else  
					r_next_state <= latch; 
					route_uart_tx_start <= '1'; 
				end if; 
			WHEN ready =>  
				route_uart_tx_start <= '0';
				
				if si_uart_start_event = '0' then
					r_next_state <= idle;
				else 
					r_next_state <= ready;
				end if; 
				 
				 
			when others => 
				r_next_state <= idle; 
			end CASE; 
 
	end if;
	end process uart_control;
	
------------------------------------
 
-- signal routings  
	so16_uart_rx_data <= r_rx_data_out; 
	so_uart_rx_rdy <= r_rx_ready_event; 
	route_uart_tx_data <= r15_uart_data_in;  
	 
end rtl;
