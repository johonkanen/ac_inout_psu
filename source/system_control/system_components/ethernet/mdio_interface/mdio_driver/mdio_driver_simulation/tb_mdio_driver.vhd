LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.mdio_driver_pkg.all;

entity tb_mdio_driver is
end;

architecture sim of tb_mdio_driver is
    signal rstn : std_logic;

    signal simulation_running  : boolean;
    signal simulator_clock     : std_logic :='0';
    signal clocked_reset       : std_logic;
    constant clock_per         : time       := 1 ns;
    constant clock_half_per    : time       := 0.5 ns;
    constant simtime_in_clocks : integer    := 196;

    signal mdio_driver_clocks   : mdio_driver_clock_group;
    signal mdio_driver_FPGA_in  : mdio_driver_FPGA_input_group;
    signal mdio_driver_FPGA_out : mdio_driver_FPGA_output_group;
    signal mdio_driver_data_in  : mdio_driver_data_input_group;
    signal mdio_driver_data_out : mdio_driver_data_output_group;

    signal simulator_counter          : natural := 0;
    signal data_from_mdio             : std_logic_vector(15 downto 0);
    signal mdio_data_out              : std_logic;
    signal mdio_clock_out             : std_logic;
    signal mdio_data_output_reference : std_logic;


    signal mdio_transmit_register : std_logic_vector(15 downto 0) := x"aaaa";
    signal mdio_receive_shift_register  : std_logic_vector(15 downto 0);
    signal mdio_clock : std_logic;
    signal mdio_clock_buffer : std_logic;
    signal mdio_clock_counter : natural range 0 to 15 := 0;
    constant mdio_clock_divisor_counter_high : integer := 4;

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
    
        end if; -- rstn
    end process clocked_reset_generator;	

------------------------------------------------------------------------
    test_mdio_driver : process(simulator_clock)
        constant reference_data_offset : integer := -4;


        
    begin
        if rising_edge(simulator_clock) then

            simulator_counter <= simulator_counter + 1;
            mdio_clock_counter <= mdio_clock_counter + 1;
            if mdio_clock_counter = mdio_clock_divisor_counter_high then 
                mdio_clock_counter <= 0;
            end if;

            mdio_clock <= '1';
            if mdio_clock_counter > mdio_clock_divisor_counter_high/2-1 then
                mdio_clock <= '0'; 
            end if; 

            if mdio_clock_counter = mdio_clock_divisor_counter_high/2-1 then
                mdio_transmit_register <= mdio_transmit_register(mdio_transmit_register'left-1 downto 0) & '0';
            end if;

            mdio_clock_buffer <= mdio_driver_FPGA_out.mdio_clock;
            if mdio_clock_buffer = '1' and mdio_driver_FPGA_out.mdio_clock = '0' then
                mdio_receive_shift_register <= mdio_receive_shift_register(mdio_receive_shift_register'left-1 downto 0) & mdio_driver_FPGA_out.MDIO_serial_data_out;
            end if;

            CASE simulator_counter is
                WHEN 82 => 
                    mdio_transmit_register <= x"acdc";
                WHEN others =>
            end CASE;



        end if; --rising_edge
    end process test_mdio_driver;	

    
    mdio_driver_clocks <= (clock => simulator_clock,
                          reset_n => clocked_reset);

    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        mdio_driver_FPGA_out ,
        mdio_driver_data_in  ,
        mdio_driver_data_out);

------------------------------------------------------------------------
end sim;
