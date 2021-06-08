library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mdio_driver_internal_pkg.all;
    use work.mdio_driver_pkg.all;

entity mdio_driver is
    port (
        mdio_driver_clocks : in mdio_driver_clock_group;

        mdio_driver_FPGA_in  : in mdio_driver_FPGA_input_group;
        mdio_driver_FPGA_out : out mdio_driver_FPGA_output_group;

        mdio_driver_data_in  : in mdio_driver_data_input_group;
        mdio_driver_data_out : out mdio_driver_data_output_group
    );
end mdio_driver;

architecture rtl of mdio_driver is

    alias mdio_data_read_is_requested is mdio_driver_data_in.mdio_data_read_is_requested;
    alias mdio_data_write_is_requested is mdio_driver_data_in.mdio_data_write_is_requested;
    alias phy_address is mdio_driver_data_in.phy_address;
    alias phy_register_address is mdio_driver_data_in.phy_register_address;
    alias core_clock is mdio_driver_clocks.clock;
    alias reset_n is mdio_driver_clocks.reset_n;

    signal mdio_clock : std_logic;

    constant MDIO_write_command : std_logic_vector(5 downto 0) := "110101";
    constant MDIO_read_command  : std_logic_vector(5 downto 0) := "110110";

    -- TODO, make an array for registers

    signal mdio_transmit_shift_register : std_logic_vector(15 downto 0);
    signal mdio_receive_shift_register  : std_logic_vector(15 downto 0);

    signal bit_counter : integer range 0 to 2**8-1;
    signal clock_divisor_counter : integer range 0 to 7;

    signal falling_edge_counter : integer := 0;
    constant number_of_clocks_in_bit : integer := 5;
    signal mdio_requested : boolean;

begin

    mdio_driver_FPGA_out.MDIO_serial_data_out <= mdio_transmit_shift_register(15);
    mdio_driver_FPGA_out.mdio_clock <= mdio_clock;

------------------------------------------------------------------------
    mdio_io_driver : process(core_clock)

    --------------------------------------------------
        type t_mdio_states is (idle, send_phy_read_command, send_read_command_address, read_data, 
                                    send_phy_write_command, send_write_command_address, write_data);

        variable st_mdio_states : t_mdio_states;
        variable mdio_command : std_logic_vector(5 downto 0);
    --------------------------------------------------
    begin
        if rising_edge(core_clock) then
            if reset_n = '0' then
            -- reset state
                mdio_clock <='0'; 
                mdio_transmit_shift_register <= x"ffff";
                mdio_receive_shift_register <= x"0000";
                clock_divisor_counter <= 0;
                mdio_requested <= false;
                mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '0';
                -- set_mdio_direction_to_write(mdio_driver_FPGA_out);
                mdio_command := MDIO_read_command;
            else

                --- create 25 MHz mdio clock -----
                clock_divisor_counter <= clock_divisor_counter + 1;
                if clock_divisor_counter = number_of_clocks_in_bit-1 then
                    clock_divisor_counter <= 0;
                end if;

                mdio_clock <= '1';
                if clock_divisor_counter > number_of_clocks_in_bit/2 then
                    mdio_clock <= '0';
                end if;

                --------------------- mdio output register -----------------------------
                if clock_divisor_counter = 3 then
                    mdio_transmit_shift_register <= mdio_transmit_shift_register(14 downto 0) & '1';
                end if;

                --------------------- mdio input register -----------------------------
                if clock_divisor_counter = 3 then
                    mdio_receive_shift_register    <= mdio_receive_shift_register(14 downto 0) & '0';
                    mdio_receive_shift_register(0) <= mdio_driver_FPGA_in.MDIO_serial_data_in;
                end if;

                mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '0';
                mdio_driver_data_out.mdio_driver_is_ready <= false;
                --------------------- main state machine for mdio io control ---------
                CASE st_mdio_states is 
                    WHEN idle =>
                        -- wait for command

                        bit_counter <= 0;

                        st_mdio_states := idle;
                        if mdio_data_read_is_requested then
                            mdio_requested <= true;
                            mdio_command := MDIO_read_command;
                        end if;

                        if mdio_data_write_is_requested then
                            mdio_requested <= true;
                            mdio_command := MDIO_write_command;
                        end if;

                        if mdio_requested AND clock_divisor_counter = 3 then
                            mdio_requested <= false;
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';
                            mdio_transmit_shift_register(15 downto 15-5) <= mdio_command;
                            falling_edge_counter <= 1;
                            if mdio_command = MDIO_read_command then
                                st_mdio_states := send_phy_read_command;
                            else
                                st_mdio_states := send_phy_write_command;
                            end if;
                        end if;

                ---------------- read branch --------------------     
                    WHEN send_phy_read_command =>
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';

                            bit_counter <= bit_counter + 1;

                        st_mdio_states := send_phy_read_command;
                        if bit_counter = 29 then
                            transmit_phy_command_address(mdio_transmit_shift_register, phy_address, phy_register_address);
                            st_mdio_states := send_read_command_address;
                            bit_counter <= 0;
                            falling_edge_counter <= 0;
                        end if;

                    WHEN send_read_command_address =>
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';

                        bit_counter <= bit_counter + 1;

                        if bit_counter = 58 then
                            bit_counter <= 0;
                            st_mdio_states := read_data;
                            -- mdio_transmit_shift_register <= "ZZZZZZZZZZZZZZZZ";
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '0';

                        end if;

                    WHEN read_data =>
                        mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '0';

                        bit_counter <= bit_counter + 1;
                        if bit_counter = 78 then
                            bit_counter <= 0;
                            st_mdio_states := idle;
                            mdio_driver_data_out.data_from_mdio <= mdio_receive_shift_register;
                            mdio_driver_data_out.mdio_driver_is_ready <= true;
                        end if;

                ---------------- write branch --------------------     
                    WHEN send_phy_write_command =>
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';

                            bit_counter <= bit_counter + 1;

                        st_mdio_states := send_phy_write_command;
                        if bit_counter = 29 then
                            transmit_phy_command_address(mdio_transmit_shift_register, phy_address, phy_register_address);
                            st_mdio_states := send_write_command_address;
                            bit_counter <= 0;
                            falling_edge_counter <= 0;
                        end if;

                    WHEN send_write_command_address =>
                            mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';

                        bit_counter <= bit_counter + 1;

                        st_mdio_states := send_write_command_address;
                        if bit_counter = 60 then
                            bit_counter <= 0;
                            st_mdio_states := write_data;
                            mdio_transmit_shift_register <= mdio_driver_data_in.data_to_mdio;
                        end if;

                    WHEN write_data =>
                        mdio_driver_FPGA_out.MDIO_io_direction_1_output <= '1';

                        st_mdio_states := write_data;
                        bit_counter <= bit_counter + 1;
                        if bit_counter = 78 then
                            bit_counter <= 0;
                            st_mdio_states := idle;
                            mdio_driver_data_out.mdio_driver_is_ready <= true;
                        end if;


                end CASE;
            end if; -- rstn
        end if; --rising_edge
    end process mdio_io_driver;	


end rtl;
