LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.ethernet_clocks_pkg.all;
    use work.ethernet_frame_receiver_pkg.all;
    use work.PCK_CRC32_D8.all;

entity tb_ethernet_frame_receiver is
end;

architecture sim of tb_ethernet_frame_receiver is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 105;

    signal ethernet_frame_receiver_clocks   : ethernet_rx_ddr_clock_group;
    signal ethernet_frame_receiver_FPGA_in  : ethernet_frame_receiver_FPGA_input_group;
    signal ethernet_frame_receiver_data_in  : ethernet_frame_receiver_data_input_group;
    signal ethernet_frame_receiver_data_out : ethernet_frame_receiver_data_output_group;

    signal simulation_counter : natural := 0;

    type std_array is array (integer range 0 to 11) of std_logic_vector(3 downto 0);
    constant test_array : std_array := (x"1",x"0",x"3",x"2",x"5",x"4",x"7",x"6",x"9",x"8",x"b",x"a");

    
    signal shift_register : std_logic_vector(11 downto 0) := (others => '0');
    signal test_data : std_logic_vector(3 downto 0);
    signal toggled : boolean;

    function reverse_bits
    (
        std_vector : std_logic_vector 
    )
    return std_logic_vector 
    is
        variable reordered_vector : std_logic_vector(std_vector'high downto 0);
    begin
        for i in std_vector'range loop
            reordered_vector(i) := std_vector(std_vector'high - i);
        end loop;
        return reordered_vector;
    end reverse_bits;

    function reverse_bit_order
    (
        std_vector : std_logic_vector 
    )
    return std_logic_vector 
    is
        variable reordered_vector : std_logic_vector(7 downto 0);
    begin
        for i in reordered_vector'range loop
            reordered_vector(i) := std_vector(std_vector'left - i);
        end loop;
        return reordered_vector;
    end reverse_bit_order;

    constant ethernet_test_frame_in_order : std_logic_vector := x"ffffffffffffc46516ae5e4f08004500004e3ca700008011574aa9fe52b1a9feffff00890089003a567b91c9011000010000000000002045454542454f454745504644464443414341434143414341434143414341424d000020000155c9b04d";
    signal ethernet_test_frame_in_big_endian : std_logic_vector(ethernet_test_frame_in_order'high downto 0) := reverse_bits(ethernet_test_frame_in_order);

    signal test_framee_length : natural := ethernet_test_frame_in_big_endian'high;

    signal fcs_shift_register : std_logic_vector(31 downto 0) := (others => '1');
    signal checksum : std_logic_vector(31 downto 0) := (others => '0');

    function invert_bit_order
    (
        std_vector : std_logic_vector(31 downto 0)
    )
    return std_logic_vector 
    is
        variable reordered_vector : std_logic_vector(31 downto 0);
    begin
        for i in reordered_vector'range loop
            reordered_vector(i) := std_vector(std_vector'left - i);
        end loop;
        return reordered_vector;
    end invert_bit_order;



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
        variable data : std_logic_vector(3 downto 0);
    begin
        if rstn = '0' then
        -- reset state
            clocked_reset <= '0';
    
        elsif rising_edge(simulator_clock) then
            clocked_reset <= '1';

            if simulation_counter < 11 then
                simulation_counter <= simulation_counter + 1;
            else
                simulation_counter <= 0;
            end if;
            data := test_array(simulation_counter);
            shift_register <= shift_register(7 downto 0) & data;

            if simulation_counter > 0 then
                toggled <= not toggled;
                if toggled then
                    test_data <= shift_register(7 downto 4);
                else
                    test_data <= data;
                end if;
            else
                toggled <= false;
            end if;

            ethernet_test_frame_in_big_endian <= ethernet_test_frame_in_big_endian(ethernet_test_frame_in_big_endian'left-8 downto 0) & x"00";
            fcs_shift_register <= nextCRC32_D8(reverse_bit_order(ethernet_test_frame_in_big_endian(ethernet_test_frame_in_big_endian'left downto ethernet_test_frame_in_big_endian'left-7)), fcs_shift_register);
            checksum <= invert_bit_order(not (nextCRC32_D8(reverse_bit_order(ethernet_test_frame_in_big_endian(ethernet_test_frame_in_big_endian'left downto ethernet_test_frame_in_big_endian'left-7)), fcs_shift_register)));
    
        end if; -- rstn
    end process clocked_reset_generator;	
------------------------------------------------------------------------

    -- ethernet_frame_receiver_clocks <= (clock => simulator_clock);
    --
    -- u_ethernet_frame_receiver : ethernet_frame_receiver
    -- port map( ethernet_frame_receiver_clocks,
    -- 	  ethernet_frame_receiver_FPGA_in,
    -- 	  ethernet_frame_receiver_data_in,
    -- 	  ethernet_frame_receiver_data_out);
end sim;
