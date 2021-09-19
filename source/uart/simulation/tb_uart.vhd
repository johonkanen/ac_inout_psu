LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.uart_pkg.all;

entity tb_uart is
end;

architecture sim of tb_uart is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 800;

    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal simulation_counter : natural := 3;
    signal uart_tx : std_logic;

    signal data_from_uart : natural := 0;

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
        function "-"
        (
            left : natural;
            right : integer
        )
        return natural
        is
            variable usigned_left : unsigned(30 downto 0);
            variable usigned_right : unsigned(30 downto 0);
        begin
            usigned_left := to_unsigned(left,31);
            usigned_right := to_unsigned(right,31);
            return to_integer(usigned_left - usigned_right);
        end "-";
    begin
        if rstn = '0' then
        -- reset state
            clocked_reset <= '0';
    
        elsif rising_edge(simulator_clock) then
            clocked_reset <= '1';
            init_uart(uart_data_in);
            simulation_counter <= simulation_counter - 1;

            CASE simulation_counter is
                when 0 => simulation_counter <= 650;
                when 3 => 
                    transmit_16_bit_word_with_uart(uart_data_in, 44252);
                when others =>
            end CASE;

            receive_data_from_uart(uart_data_out, data_from_uart);

    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

    uart_FPGA_in.uart_rx <= uart_FPGA_out.uart_tx;
    uart_tx <= uart_FPGA_out.uart_tx;
    uart_clocks <= (clock => simulator_clock);

    u_uart : uart
    port map( uart_clocks,
    	  uart_FPGA_in,
    	  uart_FPGA_out,
    	  uart_data_in,
    	  uart_data_out);
end sim;
