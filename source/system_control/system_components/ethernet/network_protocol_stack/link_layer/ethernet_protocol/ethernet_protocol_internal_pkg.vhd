library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.ethernet_frame_ram_read_pkg.all;

package ethernet_protocol_internal_pkg is

    constant ethertype_ipv4 : std_logic_vector(15 downto 0) := x"0800";
    constant ethernet_frame_length : natural := 14;

------------------------------------------------------------------------
    function toggle_detected_in ( shift_vector : std_logic_vector )
        return boolean;
------------------------------------------------------------------------

end package ethernet_protocol_internal_pkg;


package body ethernet_protocol_internal_pkg is

------------------------------------------------------------------------
    function toggle_detected_in
    (
        shift_vector : std_logic_vector 
    )
    return boolean
    is
    begin
        return shift_vector(shift_vector'left) = '0' AND shift_vector(shift_vector'left-1) = '1';
    end toggle_detected_in;

------------------------------------------------------------------------
end package body ethernet_protocol_internal_pkg; 
