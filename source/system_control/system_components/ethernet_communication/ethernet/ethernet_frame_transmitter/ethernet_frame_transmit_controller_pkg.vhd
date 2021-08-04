library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.PCK_CRC32_D8.all;

package ethernet_frame_transmit_controller_pkg is
------------------------------------------------------------------------
    type list_of_frame_transmitter_states is (idle, transmit_preable, transmit_data, transmit_fcs); 

    type frame_transmitter_record is record
        frame_transmitter_state : list_of_frame_transmitter_states;
        fcs_shift_register : std_logic_vector(31 downto 0);
        fcs : std_logic_vector(31 downto 0);
        byte_counter : natural range 0 to 2**12-1;
        frame_length : natural range 0 to 2**12-1;
        byte : std_logic_vector(7 downto 0);
    end record;

    constant init_transmit_controller : frame_transmitter_record := (frame_transmitter_state => idle,
                                                                    fcs_shift_register       => (others => '1'),
                                                                    fcs                      => (others => '0'),
                                                                    byte_counter             => 0,
                                                                    frame_length             => 60,
                                                                    byte                     => x"00");
------------------------------------------------------------------------
    procedure create_transmit_controller (
        signal transmit_controller : inout frame_transmitter_record);
------------------------------------------------------------------------
    procedure transmit_ethernet_frame (
        signal transmit_controller : inout frame_transmitter_record;
        number_of_bytes_to_transmit : natural range 0 to 2047);

------------------------------------------------------------------------
end package ethernet_frame_transmit_controller_pkg;

package body ethernet_frame_transmit_controller_pkg is

--------------------------------------------------
-------- test function ---------------------------
    type bytearray is array (integer range 0 to 95) of std_logic_vector(7 downto 0);
    constant ethernet_test_frame_in_order : bytearray := (x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"c4", x"65", x"16", x"ae", x"5e", x"4f", x"08", x"00", x"45", x"00", x"00", x"4e", x"3c", x"a7", x"00", x"00", x"80", x"11", x"57", x"4a", x"a9", x"fe", x"52", x"b1", x"a9", x"fe", x"ff", x"ff", x"00", x"89", x"00", x"89", x"00", x"3a", x"56", x"7b", x"91", x"c9", x"01", x"10", x"00", x"01", x"00", x"00", x"00", x"00", x"00", x"00", x"20", x"45", x"45", x"45", x"42", x"45", x"4f", x"45", x"47", x"45", x"50", x"46", x"44", x"46", x"44", x"43", x"41", x"43", x"41", x"43", x"41", x"43", x"41", x"43", x"41", x"43", x"41", x"43", x"41", x"43", x"41", x"42", x"4d", x"00", x"00", x"20", x"00", x"01", x"4d", x"b0", x"c9", x"55");
    -- ff ff ff ff ff ff c4 65 16 ae 5e 4f 08 00 45 00 00 4e 3c a7 00 00 80 11 57 4a a9 fe 52 b1 a9 fe ff ff 00 89 00 89 00 3a 56 7b 91 c9 01 10 00 01 00 00 00 00 00 00 20 45 45 45 42 45 4f 45 47 45 50 46 44 46 44 43 41 43 41 43 41 43 41 43 41 43 41 43 41 43 41 42 4d 00 00 20 00 01 4d b0 c9 55
    constant ethernet_test_frame_in_order_2 : std_logic_vector := x"01005e000016c46516ae5e4f08004600002890d900000102b730a9fe52b1e0000016940400002200f9010000000104000000e00000fc000000000000fe50b726";
    -- 01 00 5e 00 00 16 c4 65 16 ae 5e 4f 08 00 46 00 00 28 90 d9 00 00 01 02 b7 30 a9 fe 52 b1 e0 00 00 16 94 04 00 00 22 00 f9 01 00 00 00 01 04 00 00 00 e0 00 00 fc 00 00 00 00 00 00 fe 50 b7 26

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
------------------------------------------------------------------------
    procedure create_transmit_controller
    (
        signal transmit_controller : inout frame_transmitter_record
    ) is
        alias frame_transmitter_state is transmit_controller.frame_transmitter_state;
        alias fcs_shift_register      is transmit_controller.fcs_shift_register;
        alias fcs                     is transmit_controller.fcs;
        alias byte_counter            is transmit_controller.byte_counter;
        alias frame_length            is transmit_controller.frame_length;
        alias byte                    is transmit_controller.byte;

        variable data_to_ethernet : std_logic_vector(7 downto 0);
    begin
        CASE frame_transmitter_state is
            WHEN idle =>
                byte_counter <= 0;
                fcs_shift_register <= (others => '1');
                byte <= x"31";
            WHEN transmit_preable =>
                fcs_shift_register <= (others => '1');
                byte_counter <= byte_counter + 1;
                if byte_counter < 7 then
                    byte <= x"aa";
                end if;

                frame_transmitter_state <= transmit_preable;
                if byte_counter = 7 then
                    byte <= x"ab";
                    frame_transmitter_state <= transmit_data;
                    byte_counter <= 0;
                end if;
            WHEN transmit_data => 

                byte_counter <= byte_counter + 1; 
                data_to_ethernet := std_logic_vector(to_unsigned(byte_counter,8));
                if byte_counter < frame_length then
                    fcs_shift_register <= nextCRC32_D8(reverse_bit_order(std_logic_vector(to_unsigned(byte_counter,8))), fcs_shift_register);
                    fcs                <= not invert_bit_order(nextCRC32_D8((std_logic_vector(to_unsigned(byte_counter,8))), fcs_shift_register));
                    byte               <= reverse_bit_order(std_logic_vector(to_unsigned(byte_counter,8)));
                end if;

                frame_transmitter_state <= transmit_data;
                if byte_counter = frame_length-1 then
                    frame_transmitter_state <= transmit_fcs;
                    byte_counter <= 0;
                end if;

            WHEN transmit_fcs => 
                fcs_shift_register <= (others => '1');
                byte_counter <= byte_counter + 1;
                fcs          <= x"ff" & fcs(fcs'left downto 8);
                byte         <= reverse_bit_order(fcs(7 downto 0));
                frame_transmitter_state <= transmit_fcs;
                if byte_counter = 3 then
                    frame_transmitter_state <= idle;
                end if;
        end CASE; 

    end create_transmit_controller;

------------------------------------------------------------------------
    procedure transmit_ethernet_frame
    (
        signal transmit_controller : inout frame_transmitter_record;
        number_of_bytes_to_transmit : natural range 0 to 2047
    ) is
        alias frame_transmitter_state is transmit_controller.frame_transmitter_state;
        alias frame_length            is transmit_controller.frame_length;
    begin
        frame_transmitter_state <= transmit_preable;
        frame_length <= number_of_bytes_to_transmit;
        
    end transmit_ethernet_frame;

end package body ethernet_frame_transmit_controller_pkg;

