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
    signal simulator_clock     : std_logic;
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
            if clocked_reset = '0' then
            -- reset state
                init_mdio_driver(mdio_driver_data_in);
                simulator_counter <= 0;
    
            else
                CASE simulator_counter is
                    WHEN 0 =>
                        mdio_data_output_reference <= '0';
                    WHEN 12 =>
                        mdio_data_output_reference <= '1';
                    WHEN 22 =>
                        mdio_data_output_reference <= '0';
                    WHEN 27 =>
                        mdio_data_output_reference <= '1';
                    WHEN 37 =>
                        mdio_data_output_reference <= '0';
                    WHEN 42 =>
                        mdio_data_output_reference <= '1';
                    WHEN 67 =>
                        mdio_data_output_reference <= '0';
                    WHEN 92 =>
                        mdio_data_output_reference <= '1';
                    WHEN 97 =>
                        mdio_data_output_reference <= '0';
                    WHEN 102 =>
                        -- set directio to input
                        mdio_data_output_reference <= '1';
                    WHEN 182 =>
                        -- set directio to output
                        mdio_data_output_reference <= '0';
                    when others => -- do nothing
                end CASE;

                simulator_counter <= simulator_counter + 1;
                init_mdio_driver(mdio_driver_data_in);

                init_mdio_driver(mdio_driver_data_in);
                CASE simulator_counter is
                    WHEN 4 => 
                        read_data_from_mdio(mdio_driver_data_in,x"f0",x"0f");
                    when others =>
                        -- do nothing 
                end CASE;

                if mdio_is_ready(mdio_driver_data_out) then
                    data_from_mdio <= get_data_from_mdio(mdio_driver_data_out);
                end if;
    
            end if; -- rstn
        end if; --rising_edge
    end process test_mdio_driver;	

    
    mdio_driver_clocks <= (clock => simulator_clock,
                          reset_n => clocked_reset);

    mdio_driver_FPGA_in.MDIO_serial_data_in <= mdio_driver_FPGA_out.MDIO_serial_data_out;
    mdio_data_out <= mdio_driver_FPGA_out.MDIO_serial_data_out;
    mdio_clock_out <= mdio_driver_FPGA_out.mdio_clock;

    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        mdio_driver_FPGA_in  , -- route out of fpga
        mdio_driver_FPGA_out ,
        mdio_driver_data_in  ,
        mdio_driver_data_out);

------------------------------------------------------------------------
end sim;
