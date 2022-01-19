library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.system_clocks_pkg.all;
    use work.system_control_pkg.all;
    use work.system_control_internal_pkg.all;
    use work.system_components_pkg.all;

entity system_control is
    port (
        system_clocks             : in system_clocks_group;
        system_control_FPGA_in    : in system_control_FPGA_input_group;
        system_control_FPGA_out   : out system_control_FPGA_output_group;
        system_control_FPGA_inout : inout system_control_FPGA_inout_record;
        system_control_data_in    : in system_control_data_input_group;
        system_control_data_out   : out system_control_data_output_group
    );
end entity system_control;
    

architecture rtl of system_control is

    alias core_clock is system_clocks.core_clock;
    alias reset_n    is system_clocks.pll_locked;

    signal system_components_clocks   : system_components_clock_group;
    signal system_components_data_in  : system_components_data_input_group;
    signal system_components_data_out : system_components_data_output_group;
    
begin

------------------------------------------------------------------------
    main_system_controller : process(core_clock)
    begin
        if rising_edge(core_clock) then
            if reset_n = '0' then
            -- reset state
    
            else
    
            end if; -- rstn
        end if; --rising_edge
    end process main_system_controller;	

------------------------------------------------------------------------

    u_system_components : system_components
    port map( system_clocks,
              system_control_FPGA_in.system_components_FPGA_in,
              system_control_FPGA_out.system_components_FPGA_out,
              system_control_FPGA_inout.system_components_FPGA_inout,
              system_components_data_in,
              system_components_data_out);
------------------------------------------------------------------------
end rtl;
