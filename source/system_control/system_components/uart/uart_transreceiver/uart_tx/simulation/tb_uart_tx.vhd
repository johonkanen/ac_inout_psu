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
    constant simtime_in_clocks : integer := 300;

    signal uart_tx_clocks   : uart_tx_clock_group;
    signal uart_tx_FPGA_out : uart_tx_FPGA_output_group;
    signal uart_tx_data_in  : uart_tx_data_input_group;
    signal uart_tx_data_out : uart_tx_data_output_group;

    signal simulation_counter : natural := 0;
    signal receive_register : std_logic_vector(9 downto 0) := (others => '0');
    signal receive_bit_counter : natural range 0 to 127 := 23/2;
    signal counter_for_number_of_received_bits : natural range 0 to 15 := 0;
    signal received_data : std_logic_vector(7 downto 0);

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
        type t_receive is (wait_for_start_bit, receive_data);
        variable st_receive : t_receive := wait_for_start_bit;
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

            CASE st_receive is 
                WHEN wait_for_start_bit => 
                    st_receive := wait_for_start_bit;
                    if uart_tx_FPGA_out.uart_tx = '0' then
                        receive_bit_counter <= 23/2;
                        st_receive := receive_data;
                    end if;

                WHEN receive_data =>
                    if receive_bit_counter = 0 then
                        receive_bit_counter <= 23;
                        counter_for_number_of_received_bits <= counter_for_number_of_received_bits + 1;

                        if counter_for_number_of_received_bits = 10 then
                            st_receive := wait_for_start_bit;
                        else 
                            receive_register <= receive_register(receive_register'left-1 downto 0) & uart_tx_FPGA_out.uart_tx; 
                        end if;

                    else 
                        receive_bit_counter <= receive_bit_counter - 1;
                    end if;


            end CASE;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    received_data <= receive_register(8 downto 1);

    uart_tx_clocks <= (clock => simulator_clock);

    u_uart_tx : uart_tx
    port map( uart_tx_clocks,
    	  uart_tx_FPGA_out,
    	  uart_tx_data_in,
    	  uart_tx_data_out);
end sim;
