library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_internal_pkg.all;
    use work.mdio_driver_pkg.all;

entity mdio_driver is
    port (
        mdio_driver_clocks : in mdio_driver_clock_group;

        mdio_driver_FPGA_out : out mdio_driver_FPGA_output_group; 
        mdio_driver_data_in  : in mdio_driver_data_input_group;
        mdio_driver_data_out : out mdio_driver_data_output_group
    );
end mdio_driver;

architecture rtl of mdio_driver is

    alias core_clock is mdio_driver_clocks.clock;

    constant MDIO_write_command : std_logic_vector(5 downto 0) := "110101";
    constant MDIO_read_command  : std_logic_vector(5 downto 0) := "110110";

    signal mdio_receive_shift_register  : std_logic_vector(15 downto 0);

    constant mdio_clock_divisor_counter_high : integer := 4;

    type mdio_transmit_control_group is record
        mdio_transmit_register          : std_logic_vector(15 downto 0);
        mdio_clock                      : std_logic;
        mdio_clock_counter              : natural range 0 to 15;
        MDIO_io_direction_is_out_when_1 : std_logic;
    end record;

    constant mdio_transmit_control_init : mdio_transmit_control_group := (x"acdc",'0',0,'1');
    signal mdio_transmit_control : mdio_transmit_control_group := mdio_transmit_control_init;

begin

    mdio_driver_FPGA_out <= ( 
                            MDIO_serial_data_out            => mdio_transmit_control.mdio_transmit_register(15) ,
                            MDIO_io_direction_is_out_when_1 => '1'                                              ,
                            MDIO_clock                      => mdio_transmit_control.mdio_clock);

------------------------------------------------------------------------
    mdio_io_driver : process(core_clock)

    --------------------------------------------------
        type list_of_mdio_states is (idle, transmit_command, transmit_address);
        variable mdio_state : list_of_mdio_states;

        procedure generate_mdio_io_waveforms
        (
            signal mdio_transmit : inout mdio_transmit_control_group
        ) is
        begin

            mdio_transmit.mdio_clock_counter <= mdio_transmit.mdio_clock_counter + 1;
            if mdio_transmit.mdio_clock_counter = mdio_clock_divisor_counter_high then 
                mdio_transmit.mdio_clock_counter <= 0;
            end if;

            mdio_transmit.mdio_clock <= '1';
            if mdio_transmit.mdio_clock_counter > mdio_clock_divisor_counter_high/2-1 then
                mdio_transmit.mdio_clock <= '0'; 
            end if; 

            if mdio_transmit.mdio_clock_counter = mdio_clock_divisor_counter_high/2-2 then
                mdio_transmit.mdio_transmit_register <= mdio_transmit.mdio_transmit_register(mdio_transmit.mdio_transmit_register'left-1 downto 0) & '0';
            end if;
            
        end generate_mdio_io_waveforms;

    --------------------------------------------------
    begin
        if rising_edge(core_clock) then
            generate_mdio_io_waveforms(mdio_transmit_control);
        end if; --rising_edge
    end process mdio_io_driver;	


end rtl;
