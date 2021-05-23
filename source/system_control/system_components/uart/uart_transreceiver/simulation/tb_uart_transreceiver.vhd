LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.uart_transreceiver_pkg.all;

entity tb_uart_transreceiver is
end;

architecture sim of tb_uart_transreceiver is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 5000;

    signal uart_transreceiver_clocks   : uart_transreceiver_clock_group;
    signal uart_transreceiver_FPGA_in  : uart_transreceiver_FPGA_input_group;
    signal uart_transreceiver_FPGA_out : uart_transreceiver_FPGA_output_group;
    signal uart_transreceiver_data_in  : uart_transreceiver_data_input_group;
    signal uart_transreceiver_data_out : uart_transreceiver_data_output_group;

    signal simulation_counter : natural := 0;

    subtype std16 is std_logic_vector(15 downto 0);
    type std16_array is array (integer range <>) of std16;

    constant test_data : std16_array(0 to 5) := (x"ACDC", x"FFFF", x"ABBA", x"BBBA", x"FBAA", x"1515");
    signal test_data_index : natural := 0;
    signal jee : std_logic_vector(15 downto 0);
    signal delay_timer : natural := 0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        simulation_running <= true;
        wait for simtime_in_clocks*clock_per;
        simulation_running <= false;
        wait;
    end process simtime;	

------------------------------------------------------------------------
    sim_clock_gen : process
    begin
        simulator_clock <= '0';
        rstn <= '0';
        simulator_clock <= '0';
        wait for clock_half_per;
        while simulation_running loop
            wait for clock_half_per;
                rstn <= '1';
                simulator_clock <= not simulator_clock;
            end loop;
        wait;
    end process;
------------------------------------------------------------------------


    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rstn = '0' then
        -- reset state
            clocked_reset <= '0';
    
        elsif rising_edge(simulator_clock) then
            clocked_reset <= '1';
            simulation_counter <= simulation_counter + 1;
            init_uart(uart_transreceiver_data_in);

            CASE simulation_counter is
                WHEN 5 => 
                    transmit_16_bit_word_with_uart(uart_transreceiver_data_in, x"ACDC");
                    test_data_index <= test_data_index + 1;
                WHEN others => -- do nothing
            end CASE;

            -- this is triggered when test_data_index is between 1 to 6
            if uart_data_packet_has_been_received(uart_transreceiver_data_out) then
                -- assert get_received_data_packet(uart_transreceiver_data_out) = test_data(test_data_index-1); report "uart rx failed with index " & integer'image(test_data_index-1) severity failure;
                report "16 bit data packet received successfully";
                delay_timer <= 13;
            end if; 
            if delay_timer /= 0 then
                delay_timer <= delay_timer - 1;
            end if;
            if delay_timer = 1 then
                transmit_16_bit_word_with_uart(uart_transreceiver_data_in, x"ffff");
            end if;

        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    uart_transreceiver_FPGA_in <= (
                                      uart_rx_FPGA_in => (
                                                            uart_rx => uart_transreceiver_FPGA_out.uart_tx_FPGA_out.uart_tx
                                                         )
                                  );

    uart_transreceiver_clocks <= (clock => simulator_clock);

    jee <= uart_transreceiver_data_out.received_data_packet;

    u_uart_transreceiver : uart_transreceiver
    port map( uart_transreceiver_clocks,
    	  uart_transreceiver_FPGA_in,
    	  uart_transreceiver_FPGA_out,
    	  uart_transreceiver_data_in,
    	  uart_transreceiver_data_out);

end sim;
