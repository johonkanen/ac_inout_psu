library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all; 

library work;
    use work.system_clocks_pkg.all;
    use work.system_components_pkg.all;

package system_control_pkg is

type system_control_FPGA_input_group is record
    system_components_FPGA_in  : system_components_FPGA_input_group;
end record;

type system_control_FPGA_output_group is record
    system_components_FPGA_out : system_components_FPGA_output_group;
end record;

type system_control_FPGA_inout_record is record
    system_components_FPGA_inout : system_components_FPGA_inout_record;
end record;

type system_control_data_input_group is record
    system_components_data_in  : system_components_data_input_group;
end record;

type system_control_data_output_group is record
    system_components_data_out : system_components_data_output_group;
end record;

component system_control is
    port (
        system_clocks             : in system_clocks_group;
        system_control_FPGA_in    : in system_control_FPGA_input_group;
        system_control_FPGA_out   : out system_control_FPGA_output_group;
        system_control_FPGA_inout : inout system_control_FPGA_inout_record;
        system_control_data_in    : in system_control_data_input_group;
        system_control_data_out   : out system_control_data_output_group
    );
end component system_control;

-- signal system_control_clocks   : system_control_clock_group;
-- signal system_control_FPGA_in  : system_control_FPGA_input_group;
-- signal system_control_FPGA_out : system_control_FPGA_output_group;
-- signal system_control_data_in  : system_control_data_input_group;
-- signal system_control_data_out : system_control_data_output_group

-- u_system_control : system_control
-- port map( system_control_clocks,
-- 	  system_control_FPGA_in,
--	  system_control_FPGA_out,
--	  system_control_data_in,
--	  system_control_data_out);
 

end package system_control_pkg;
