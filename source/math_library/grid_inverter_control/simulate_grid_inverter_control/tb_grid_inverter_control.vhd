LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;
    use math_library.sincos_pkg.all;

entity tb_grid_inverter_control is
end;

architecture sim of tb_grid_inverter_control is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;
------------------------------------------------------------------------
    signal simulation_counter : natural := 25;

    signal multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;


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
            report "grid inverter control simulation finished";
        wait;
    end process;
------------------------------------------------------------------------

    clocked_reset_generator : process(simulator_clock, rstn)
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

end sim;
