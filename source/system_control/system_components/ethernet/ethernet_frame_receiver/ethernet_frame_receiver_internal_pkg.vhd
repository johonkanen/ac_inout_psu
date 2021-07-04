library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_receiver_pkg.all;
    use work.ethernet_rx_ddio_pkg.all; 

package ethernet_frame_receiver_internal_pkg is

    function get_ethernet_octet (
            shift_register : std_logic_vector;
            ethernet_ddio : ethernet_rx_ddio_data_output_group;
            read_data_from_buffer : boolean)
        return std_logic_vector;

end package ethernet_frame_receiver_internal_pkg;


package body ethernet_frame_receiver_internal_pkg is

    ------------------------------------------------------------------------
    function get_reversed_byte
    (
        ethernet_shift_register : std_logic_vector
    )
    return std_logic_vector 
    is
        variable byte_reversed : std_logic_vector(7 downto 0);
        variable buffered_byte : std_logic_vector(7 downto 0);
    begin
        buffered_byte := ethernet_shift_register(15 downto 8);

        byte_reversed := buffered_byte(0) &
                         buffered_byte(1) &
                         buffered_byte(2) &
                         buffered_byte(3) &
                         buffered_byte(4) &
                         buffered_byte(5) &
                         buffered_byte(6) &
                         buffered_byte(7);

        return byte_reversed; 

    end get_reversed_byte;

    ------------------------------------------------------------------------ 
    function get_ethernet_octet
    (
        shift_register : std_logic_vector;
        ethernet_ddio : ethernet_rx_ddio_data_output_group;
        read_data_from_buffer : boolean
    )
    return std_logic_vector 
    is
        variable reordered_ethernet_byte : std_logic_vector(7 downto 0);
    begin

        if read_data_from_buffer then
            reordered_ethernet_byte := get_reversed_byte(shift_register);
        else
            reordered_ethernet_byte := get_reversed_byte(ethernet_ddio);
        end if;

        return reordered_ethernet_byte;
        
    end get_ethernet_octet;
    ------------------------------------------------------------------------ 

end package body ethernet_frame_receiver_internal_pkg;

