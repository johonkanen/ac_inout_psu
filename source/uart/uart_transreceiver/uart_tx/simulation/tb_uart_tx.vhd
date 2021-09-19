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
    constant simtime_in_clocks : integer := 600;

    signal uart_tx_clocks   : uart_tx_clock_group;
    signal uart_tx_FPGA_out : uart_tx_FPGA_output_group;
    signal uart_tx_data_in  : uart_tx_data_input_group;
    signal uart_tx_data_out : uart_tx_data_output_group;

    signal simulation_counter : natural := 0;
    signal receive_register : std_logic_vector(9 downto 0) := (others => '0');
    signal receive_bit_counter : natural range 0 to 127 := 23/2;
    signal counter_for_number_of_received_bits : natural range 0 to 15 := 0;
    signal received_data : std_logic_vector(7 downto 0);

    signal counter_for_data_bit : natural := 0; 

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

        function read_bit_as_1_if_counter_higher_than
        (
            limit_for_bit_being_high : natural;
            counter_for_bit : natural 
        )
        return std_logic
        is
        begin
            if counter_for_bit > limit_for_bit_being_high then
                return '1';
            else
                return '0';
            end if;
            
        end read_bit_as_1_if_counter_higher_than;

        function "+"
        (
            left : integer;
            right : std_logic 
        )
        return integer
        is
        begin
            if right = '1' then
                return left + 1;
            else
                return left;
            end if;
        end "+";
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
                WHEN 300 =>
                    transmit_8bit_data_package(uart_tx_data_in, x"DC");
                WHEN others => -- do nothing
            end CASE;

            CASE st_receive is 
                WHEN wait_for_start_bit => 
                    counter_for_data_bit <= 0;
                    counter_for_number_of_received_bits <= 0;
                    st_receive := wait_for_start_bit;
                    if uart_tx_FPGA_out.uart_tx = '0' then
                        receive_bit_counter <= bit_counter_high;
                        st_receive := receive_data;
                    end if;

                WHEN receive_data =>
                    counter_for_data_bit <= counter_for_data_bit + uart_tx_FPGA_out.uart_tx;
                    if receive_bit_counter = 0 then
                        receive_bit_counter <= bit_counter_high;
                        counter_for_number_of_received_bits <= counter_for_number_of_received_bits + 1;

                        if counter_for_number_of_received_bits = total_number_of_transmitted_bits_per_word then
                            st_receive := wait_for_start_bit;
                            counter_for_number_of_received_bits <= 0;
                        else 
                            receive_register <= receive_register(receive_register'left-1 downto 0) & read_bit_as_1_if_counter_higher_than(bit_counter_high/2-1, counter_for_data_bit); 
                            counter_for_data_bit <= 0;
                        end if;

                    else 
                        receive_bit_counter <= receive_bit_counter - 1;
                    end if; 
            end CASE;

            if uart_tx_is_ready(uart_tx_data_out) then
                received_data <= receive_register(7 downto 0);
            end if; 
    
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
