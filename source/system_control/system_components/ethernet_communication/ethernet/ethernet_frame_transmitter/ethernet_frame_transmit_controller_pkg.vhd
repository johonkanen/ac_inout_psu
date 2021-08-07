library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.PCK_CRC32_D8.all;
    use work.ethernet_frame_ram_read_pkg.all; 

package ethernet_frame_transmit_controller_pkg is
------------------------------------------------------------------------
    type list_of_frame_transmitter_states is (idle, transmit_preable, transmit_data, transmit_fcs); 

    type frame_transmitter_record is record
        frame_transmitter_state  : list_of_frame_transmitter_states;
        fcs_shift_register       : std_logic_vector(31 downto 0);
        fcs                      : std_logic_vector(31 downto 0);
        byte_counter             : natural range 0 to 2**12-1;
        frame_length             : natural range 0 to 2**12-1;
        byte                     : std_logic_vector(7 downto 0);
        frame_transmit_requested : boolean;
        test_counter             : natural range 0 to 255;
        ram_shift_register       : std_logic_vector(31 downto 0);
        ram_read_controller      : ram_reader;
    end record;

    constant init_transmit_controller : frame_transmitter_record := (frame_transmitter_state => idle            ,
                                                                    fcs_shift_register       => (others => '1') ,
                                                                    fcs                      => (others => '0') ,
                                                                    byte_counter             => 0               ,
                                                                    frame_length             => 60              ,
                                                                    byte                     => x"00"           ,
                                                                    frame_transmit_requested => false           ,
                                                                    test_counter             => 0               ,
                                                                    ram_shift_register       => (others => '0') ,
                                                                    ram_read_controller      => ram_reader_init
                                                                );
------------------------------------------------------------------------
    procedure create_transmit_controller (
        signal transmit_controller : inout frame_transmitter_record);
------------------------------------------------------------------------
    procedure transmit_ethernet_frame (
        signal transmit_controller : inout frame_transmitter_record;
        number_of_bytes_to_transmit : natural range 0 to 2047);
------------------------------------------------------------------------
    function frame_transmit_is_requested ( transmit_controller : frame_transmitter_record)
        return boolean;
------------------------------------------------------------------------
end package ethernet_frame_transmit_controller_pkg;

package body ethernet_frame_transmit_controller_pkg is

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
        alias frame_transmitter_state  is transmit_controller.frame_transmitter_state;
        alias fcs_shift_register       is transmit_controller.fcs_shift_register;
        alias fcs                      is transmit_controller.fcs;
        alias byte_counter             is transmit_controller.byte_counter;
        alias frame_length             is transmit_controller.frame_length;
        alias byte                     is transmit_controller.byte;
        alias test_counter             is transmit_controller.test_counter;
        alias frame_transmit_requested is transmit_controller.frame_transmit_requested;

        variable data_to_ethernet : std_logic_vector(7 downto 0);
    begin
        test_counter <= 0;
        frame_transmit_requested <= false;
        CASE frame_transmitter_state is
            WHEN idle =>
                byte_counter <= 0;
                fcs_shift_register <= (others => '1');
                byte <= x"00";
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

                    load_ram_with_offset_to_shift_register(ram_controller                     => transmit_controller.ram_read_controller ,
                                                           start_address                      => 0                   ,
                                                           number_of_ram_addresses_to_be_read => 60);

                end if;
            WHEN transmit_data => 

                test_counter <= test_counter + 1;
                data_to_ethernet := reverse_bit_order(transmit_controller.ram_shift_register(7 downto 0));


                byte_counter <= byte_counter + 1; 
                if byte_counter < frame_length then
                    fcs_shift_register <= nextCRC32_D8(data_to_ethernet, fcs_shift_register);
                    fcs                <= not invert_bit_order(nextCRC32_D8(data_to_ethernet, fcs_shift_register));
                    byte               <= data_to_ethernet;
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
                    byte_counter <= 0;
                    frame_transmit_requested <= true;
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

------------------------------------------------------------------------
    function frame_transmit_is_requested
    (
        transmit_controller : frame_transmitter_record
    )
    return boolean
    is
    begin
        return transmit_controller.frame_transmit_requested;
    end frame_transmit_is_requested; 

------------------------------------------------------------------------
end package body ethernet_frame_transmit_controller_pkg; 
