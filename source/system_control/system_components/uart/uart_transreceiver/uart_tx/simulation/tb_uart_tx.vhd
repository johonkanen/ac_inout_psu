LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.uart_tx_pkg.all;

entity tb_uart_tx is
end;

architecture sim of tb_uart_tx is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 150;

    signal uart_tx_clocks   : uart_tx_clock_group;
    signal uart_tx_FPGA_out : uart_tx_FPGA_output_group;
    signal uart_tx_data_in  : uart_tx_data_input_group;
    signal uart_tx_data_out : uart_tx_data_output_group;

    signal simulation_counter : natural := 0;

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
            init_uart(uart_tx_data_in);

            CASE simulation_counter is
                WHEN 5 =>
                    transmit_8bit_data_package(uart_tx_data_in, x"AC");
                WHEN others => -- do nothing
            end CASE;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

    uart_tx_clocks <= (clock => simulator_clock);

    u_uart_tx : uart_tx
    port map( uart_tx_clocks,
    	  uart_tx_FPGA_out,
    	  uart_tx_data_in,
    	  uart_tx_data_out);
end sim;
