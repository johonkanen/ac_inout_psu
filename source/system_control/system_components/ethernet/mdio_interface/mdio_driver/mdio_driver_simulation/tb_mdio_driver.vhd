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

    signal mdio_receive_shift_register  : std_logic_vector(33 downto 0) := (others => '0');
    signal mdio_clock_buffer : std_logic;

    signal mdio_clock : std_logic;
    signal mdio_serial_data : std_logic;
    signal mdio_write_is_ready : boolean;

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

            init_mdio_driver(mdio_driver_data_in);
            if simulator_counter = 10 then
                write_data_to_mdio(mdio_driver_data_in, x"1f", x"1f", x"acdc");
            end if;

            mdio_clock_buffer <= mdio_driver_FPGA_out.mdio_clock;
            if mdio_clock_buffer = '1' and mdio_driver_FPGA_out.mdio_clock = '0' then
                mdio_receive_shift_register <= mdio_receive_shift_register(mdio_receive_shift_register'left-1 downto 0) & mdio_driver_FPGA_out.MDIO_serial_data_out;
            end if;

            if mdio_data_write_is_ready(mdio_driver_data_out) then
                -- assert mdio_receive_shift_register = "11" & x"5ffeacdc" report " not jee " severity failure;
                report "mdio write is ready";
                read_data_from_mdio(mdio_driver_data_in, x"1f", x"1f");
            end if;

        end if; --rising_edge
    end process test_mdio_driver;	

    mdio_serial_data <= mdio_driver_FPGA_out.MDIO_serial_data_out;
    mdio_clock <= mdio_driver_FPGA_out.mdio_clock;
    
    mdio_driver_clocks <= (clock => simulator_clock);
    mdio_write_is_ready <= mdio_driver_data_out.mdio_write_is_ready;

    u_mdio_driver : mdio_driver
    port map(
        mdio_driver_clocks   ,
        mdio_driver_FPGA_out ,
        mdio_driver_data_in  ,
        mdio_driver_data_out);

------------------------------------------------------------------------
end sim;
