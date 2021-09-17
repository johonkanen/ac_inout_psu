LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library math_library;
    use math_library.multiplier_pkg.all;

entity tb_sincos is
end;

architecture sim of tb_sincos is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 50;
------------------------------------------------------------------------
    signal simulation_counter : natural := 0;
    signal hw_multiplier : multiplier_record := init_multiplier;

    signal process_counter : natural := 0;
    signal angle_rad16 : natural := 0;

    --------------------------------------------------
    function angle_reduction
    (
        angle_in_rad16 : natural
    )
    return natural
    is 
        variable unsigned_angle : unsigned(15 downto 0);
        variable reduced_angle : natural;
    begin
        unsigned_angle := to_unsigned(angle_in_rad16,16);
        reduced_angle := to_integer(unsigned_angle(12 downto 0)); 
        return reduced_angle;
    end angle_reduction;
    --------------------------------------------------

    signal test_reduced_angle : natural := 0;

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
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            angle_rad16 <= angle_rad16 + 1024;

            test_reduced_angle <= angle_reduction(angle_rad16);
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------ 
end sim;
