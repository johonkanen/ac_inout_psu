library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.internet_protocol_pkg.all;

entity internet_protocol is
    port (
        internet_protocol_clocks : in internet_protocol_clock_group; 
        internet_protocol_data_in : in internet_protocol_data_input_group;
        internet_protocol_data_out : out internet_protocol_data_output_group
    );
end entity internet_protocol;

architecture rtl of internet_protocol is

    
begin


end rtl;

