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

    signal ethernet_ddio : std_logic_vector(3 downto 0);
    signal byte : std_logic_vector(7 downto 0);

------------------------------------------------------------------------
    alias core_clock is simulator_clock;
    alias reset_n is clocked_reset;
    signal ethernet_clocks   : ethernet_clock_group;
    
--------------------------------------------------
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

--------------------------------------------------
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

--------------------------------------------------
    constant ethernet_test_frame_in_order : std_logic_vector := x"ffffffffffffc46516ae5e4f08004500004e3ca700008011574aa9fe52b1a9feffff00890089003a567b91c9011000010000000000002045454542454f454745504644464443414341434143414341434143414341424d00002000014db0c955"; 
    -- ff ff ff ff ff ff c4 65 16 ae 5e 4f 08 00 45 00 00 4e 3c a7 00 00 80 11 57 4a a9 fe 52 b1 a9 fe ff ff 00 89 00 89 00 3a 56 7b 91 c9 01 10 00 01 00 00 00 00 00 00 20 45 45 45 42 45 4f 45 47 45 50 46 44 46 44 43 41 43 41 43 41 43 41 43 41 43 41 43 41 43 41 42 4d 00 00 20 00 01 4d b0 c9 55
    constant ethernet_test_frame_in_order_2 : std_logic_vector := x"01005e000016c46516ae5e4f08004600002890d900000102b730a9fe52b1e0000016940400002200f9010000000104000000e00000fc000000000000fe50b726";
    -- 01 00 5e 00 00 16 c4 65 16 ae 5e 4f 08 00 46 00 00 28 90 d9 00 00 01 02 b7 30 a9 fe 52 b1 e0 00 00 16 94 04 00 00 22 00 f9 01 00 00 00 01 04 00 00 00 e0 00 00 fc 00 00 00 00 00 00 fe 50 b7 26


    type list_of_frame_transmitter_states is (idle, transmit_preable, transmit_data, transmit_fcs);
    

    type frame_transmitter_record is record
        frame_transmitter_state : list_of_frame_transmitter_states;
        fcs_shift_register : std_logic_vector(31 downto 0);
        fcs : std_logic_vector(31 downto 0);
        byte_counter : natural;
        frame_length : natural;
        byte : std_logic_vector(7 downto 0);
    end record;

    constant init_transmit_controller : frame_transmitter_record := (frame_transmitter_state => idle,
                                                                    fcs_shift_register       => (others => '1'),
                                                                    fcs                      => (others => '0'),
                                                                    byte_counter             => 0,
                                                                    frame_length             => 93,
                                                                    byte => x"00");

    signal frame_transmit_controller : frame_transmitter_record := init_transmit_controller;

--------------------------------------------------
-------- test function ---------------------------
    function get_byte_from_vector
    (
        frame_data_vector : std_logic_vector;
        byte_order : natural
    )
    return std_logic_vector 
    is
    begin
        return frame_data_vector(byte_order*8 to byte_order*8+7);

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

        
    begin
        if rising_edge(simulator_clock) then
            if clocked_reset = '0' then
            -- reset state
                simulator_counter <= 0;
            else
                simulator_counter <= simulator_counter + 1;

                CASE frame_transmit_controller.frame_transmitter_state is
                    WHEN idle =>
                        frame_transmit_controller.frame_transmitter_state <= transmit_preable;
                        frame_transmit_controller.byte_counter <= 0;
                    WHEN transmit_preable =>
                        frame_transmit_controller.byte_counter <= frame_transmit_controller.byte_counter + 1;
                        if frame_transmit_controller.byte_counter < 7 then
                            frame_transmit_controller.byte <= x"aa";
                        end if;
                        if frame_transmit_controller.byte_counter = 8 then
                            frame_transmit_controller.byte <= x"ab";
                            frame_transmit_controller.frame_transmitter_state <= transmit_data;
                            frame_transmit_controller.byte_counter <= 0;
                        end if;
                    WHEN transmit_data => 

                        frame_transmit_controller.byte_counter <= frame_transmit_controller.byte_counter + 1; 
                        data_to_ethernet := get_byte_from_vector(ethernet_test_frame_in_order, frame_transmit_controller.byte_counter);
                        if frame_transmit_controller.byte_counter < frame_transmit_controller.frame_length then
                            frame_transmit_controller.fcs_shift_register <= nextCRC32_D8(reverse_bit_order(data_to_ethernet), frame_transmit_controller.fcs_shift_register);
                            frame_transmit_controller.fcs                <= not invert_bit_order(nextCRC32_D8((data_to_ethernet), frame_transmit_controller.fcs_shift_register));
                            frame_transmit_controller.byte               <= data_to_ethernet;
                        end if;

                        if frame_transmit_controller.byte_counter = frame_transmit_controller.frame_length-1 then
                            frame_transmit_controller.frame_transmitter_state <= transmit_fcs;
                            frame_transmit_controller.byte_counter <= 0;
                        end if;

                    WHEN transmit_fcs =>

                        frame_transmit_controller.byte_counter <= frame_transmit_controller.byte_counter + 1; 
                        frame_transmit_controller.fcs  <= x"ff" & frame_transmit_controller.fcs(frame_transmit_controller.fcs'left downto 8);
                        frame_transmit_controller.byte <= frame_transmit_controller.fcs(7 downto 0);
                        if frame_transmit_controller.byte_counter = 3 then
                            frame_transmit_controller.frame_transmitter_state <= idle;
                            frame_transmit_controller.byte <= x"00";
                        end if;
                end CASE;


            end if; -- rstn
        end if; --rising_edge
    end process frame_transmitter_starter;	

    byte <= frame_transmit_controller.byte; 

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
