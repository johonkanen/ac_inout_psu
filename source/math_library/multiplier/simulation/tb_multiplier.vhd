LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;

entity tb_multiplier is
end;

architecture sim of tb_multiplier is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;

    signal multiplier_clocks   : multiplier_clock_group;
    signal multiplier_data_in  : multiplier_data_input_group;
    signal multiplier_data_out : multiplier_data_output_group;

    signal simulation_counter : natural := 0;
    signal multiplier_output : signed(35 downto 0);
    signal multiplier_is_ready_when_1 : std_logic;
    signal int18_multiplier_output : int18 := 0;

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

            init_multiplier(multiplier_data_in);
            CASE simulation_counter is
                WHEN 5 => multiply(multiplier_data_in, 5, 65536);
                WHEN 6 => multiply(multiplier_data_in, -25, 65536);
                WHEN 7 => multiply(multiplier_data_in, 100, 65536);
                WHEN 8 => multiply(multiplier_data_in, 1000, 65536);
                WHEN others => -- do nothing
            end CASE;
            if multiplier_is_ready(multiplier_data_out) then
                int18_multiplier_output <= get_multiplier_result(multiplier_data_out,16);
            end if;

    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------
    multiplier_output <= multiplier_data_out.multiplier_raw_result;
    multiplier_is_ready_when_1 <= multiplier_data_out.multiplier_is_ready_when_1;

    multiplier_clocks <= (clock => simulator_clock);

    u_multiplier : multiplier
    port map( multiplier_clocks,
    	  multiplier_data_in,
    	  multiplier_data_out);
end sim;
