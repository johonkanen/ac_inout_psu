library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_components_pkg.all;

library math_library;

entity system_components is
    port (
        system_clocks                : in  system_clocks_group;
        system_components_FPGA_in    : in  system_components_FPGA_input_group;
        system_components_FPGA_out   : out system_components_FPGA_output_group;
        system_components_FPGA_inout : inout system_components_FPGA_inout_record;
        system_components_data_in    : in  system_components_data_input_group;
        system_components_data_out   : out system_components_data_output_group
    );
end entity system_components;

