LIBRARY ieee  ; 
LIBRARY std  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    USE ieee.std_logic_textio.all  ; 
    use ieee.math_real.all;
    USE std.textio.all  ; 

library work;
    use work.ethernet_clocks_pkg.all;
    use work.PCK_CRC32_D8.all;

entity tb_ethernet_frame_transmitter is
end;

architecture sim of tb_ethernet_frame_transmitter is
    signal rstn : std_logic;

    signal simulation_running : boolean;
    signal simulator_clock : std_logic;
    signal clocked_reset : std_logic;
    constant clock_per : time := 1 ns;
    constant clock_half_per : time := 0.5 ns;
    constant simtime_in_clocks : integer := 150;
    signal simulator_counter : natural := 0;
    signal byte_counter : natural := 0;

    signal ethernet_ddio : std_logic_vector(3 downto 0);
    signal byte : std_logic_vector(7 downto 0);

------------------------------------------------------------------------
    alias core_clock is simulator_clock;
    alias reset_n is clocked_reset;
    signal ethernet_clocks   : ethernet_clock_group;
    
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


    constant ethernet_test_frame_in_order_2 : std_logic_vector := x"01005e000016c46516ae5e4f08004600002890d900000102b730a9fe52b1e0000016940400002200f9010000000104000000e00000fc000000000000fe50b726";
    -- 01 00 5e 00 00 16 c4 65 16 ae 5e 4f 08 00 46 00 00 28 90 d9 00 00 01 02 b7 30 a9 fe 52 b1 e0 00 00 16 94 04 00 00 22 00 f9 01 00 00 00 01 04 00 00 00 e0 00 00 fc 00 00 00 00 00 00 fe 50 b7 26
    signal fcs_shift_register : std_logic_vector(31 downto 0) := (others => '1');
    signal fcs : std_logic_vector(31 downto 0) := (others => '0');

    function get_byte_from_vector
    (
        frame_data_vector : std_logic_vector;
        byte_order : natural
    )
    return std_logic_vector 
    is
    begin
        if byte_order < 60 then
            return frame_data_vector(byte_order*8 to byte_order*8+7);
        else
            return x"00";
        end if;

    end get_byte_from_vector;

------------------------------------------------------------------------
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

    frame_transmitter_starter : process(simulator_clock)

        variable data_to_ethernet : std_logic_vector(7 downto 0);

        type list_of_frame_transmitter_states is (idle, transmit_preable, transmit_data, transmit_fcs);
        variable frame_transmitter_state : list_of_frame_transmitter_states;
        
    begin
        if rising_edge(simulator_clock) then
            if clocked_reset = '0' then
            -- reset state
                simulator_counter <= 0;
                byte_counter <= 0;
            else
                simulator_counter <= simulator_counter + 1;

                CASE frame_transmitter_state is
                    WHEN idle =>
                        frame_transmitter_state := transmit_preable;
                        byte_counter <= 0;
                    WHEN transmit_preable =>
                        byte_counter <= byte_counter + 1;
                        if byte_counter < 7 then
                            byte <= x"aa";
                        end if;
                        if byte_counter = 8 then
                            byte <= x"ab";
                            frame_transmitter_state := transmit_data;
                            byte_counter <= 0;
                        end if;
                    WHEN transmit_data => 

                        byte_counter <= byte_counter + 1; 
                        data_to_ethernet := get_byte_from_vector(ethernet_test_frame_in_order_2, byte_counter);
                        if byte_counter < 60 then
                            fcs_shift_register <= nextCRC32_D8(reverse_bit_order(data_to_ethernet), fcs_shift_register);
                            fcs                <= not invert_bit_order(nextCRC32_D8((data_to_ethernet), fcs_shift_register));
                            byte               <= data_to_ethernet;
                        end if;

                        if byte_counter = 59 then
                            frame_transmitter_state := transmit_fcs;
                            byte_counter <= 0;
                        end if;

                    WHEN transmit_fcs =>

                        byte_counter <= byte_counter + 1; 
                        fcs  <= x"ff" & fcs(fcs'left downto 8);
                        byte <= fcs(7 downto 0);
                        if byte_counter = 3 then
                            frame_transmitter_state := idle;
                            byte <= x"00";
                        end if;
                end CASE;

            end if; -- rstn
        end if; --rising_edge
    end process frame_transmitter_starter;	



------------------------------------------------------------------------
------------------------------------------------------------------------
    -- ethernet_ddio   <= ethernet_frame_transmitter_FPGA_out.ethernet_tx_ddio_FPGA_out.ethernet_tx_ddio_FPGA_io;
    -- ethernet_clocks <= (core_clock, reset_n,
    --                    tx_ddr_clocks =>(core_clock, reset_n),
    --                    rx_ddr_clocks =>(core_clock, reset_n));
    --
    -- --------------------------------------------------
    -- u_ethernet_frame_transmitter : ethernet_frame_transmitter
    -- port map( ethernet_clocks,
    -- 	  ethernet_frame_transmitter_FPGA_out,
    -- 	  ethernet_frame_transmitter_data_in,
    -- 	  ethernet_frame_transmitter_data_out);
------------------------------------------------------------------------
end sim;
