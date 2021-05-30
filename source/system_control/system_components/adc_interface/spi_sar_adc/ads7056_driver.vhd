library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.numeric_std.all;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
    use work.spi_sar_adc_pkg.all;

entity spi_sar_adc is
    port (
        spi_sar_adc_clocks   : in spi_sar_adc_clock_group;
        spi_sar_adc_FPGA_in  : in spi_sar_adc_FPGA_input_group;
        spi_sar_adc_FPGA_out : out spi_sar_adc_FPGA_output_group;
        spi_sar_adc_data_in  : in spi_sar_adc_data_input_group;
        spi_sar_adc_data_out : out spi_sar_adc_data_output_group
    );
end spi_sar_adc;
 
architecture ads_7056 of spi_sar_adc is 

    alias si_spi_clk     is spi_sar_adc_clocks.clock                              ;
    alias si_pll_lock    is spi_sar_adc_clocks.reset_n                            ;
    alias pi_spi_serial  is spi_sar_adc_FPGA_in.spi_serial_data                   ;
    alias po_spi_clk_out is spi_sar_adc_FPGA_out.spi_clock                        ;
    alias po_spi_cs      is spi_sar_adc_FPGA_out.chip_select                      ;

    alias si_spi_start   is spi_sar_adc_data_in.ad_conversion_started_with_1      ;
    alias so_sh_rdy      is spi_sar_adc_data_out.adc_sample_and_hold_ready_when_1 ;
    alias so_spi_rdy     is spi_sar_adc_data_out.adc_conversion_is_ready_when_1   ;
    alias b_spi_rx       is spi_sar_adc_data_out.ad_measurement_data              ;
    alias s_spi_busy     is spi_sar_adc_data_out.adc_is_busy_when_1               ;

    constant g_u8_clk_cnt : integer := 2;
    constant g_u8_clks_per_conversion : integer := 18;
    constant g_sh_counter_latch : integer := 8; -- TODO, figure out a number for this

    signal clock_count : unsigned(3 downto 0); 
    signal spi_rx_buffer : std_logic_vector(17 downto 0);
    constant c_convert : std_logic := '0';
    constant c_idle : std_logic := '1';
    signal i : integer range 0 to 31;
    subtype t_ad_states is std_logic_vector(1 downto 0);
    constant t_idle : t_ad_states := "00";
    constant t_calibrate : t_ad_states := "11";
    constant t_convert : t_ad_states := "10";
    signal st_ad_states : t_ad_states;
    signal r_po_spi_clk_out : std_logic := '0';
    signal r_po_spi_cs : std_logic; 
    
    signal spi_process_count : natural := 0;
    signal spi_clk_div : natural := 0;

begin
    spi_control : process(si_spi_clk)
    begin
        if rising_edge(si_spi_clk) then
            if si_pll_lock = '1' then
                CASE st_ad_states is
                    WHEN t_calibrate =>
                        so_sh_rdy <= '0';
                        so_spi_rdy <= '0';
                        spi_rx_buffer <= (others => '0');  

                        spi_process_count <= spi_process_count + 1;

                        spi_clk_div <= spi_clk_div + 1;
                        if spi_clk_div = g_u8_clk_cnt-2 then
                            spi_clk_div <= 0;
                            r_po_spi_clk_out <= not r_po_spi_clk_out;
                        end if;

                        if spi_clk_div = g_u8_clk_cnt/2 - 1 then
                            r_po_spi_clk_out <= not r_po_spi_clk_out;
                            spi_rx_buffer <= spi_rx_buffer(16 downto 0) & pi_spi_serial;
                        end if;

                        if spi_process_count = g_u8_clk_cnt*to_unsigned(24,8)-g_u8_clk_cnt/2-1 then
                            st_ad_states <= t_idle;
                        else
                            st_ad_states <= t_calibrate;
                        end if;

                    WHEN t_idle =>
                        so_spi_rdy <= '0';
                        spi_process_count <= 0;
                        spi_clk_div <= 0;
                        i <= (g_u8_clks_per_conversion)+1;
                        so_sh_rdy <= '0';

                        if si_spi_start = '1' then
                            st_ad_states <= t_convert;
                            r_po_spi_clk_out <= '0';
                        else
                            st_ad_states <= t_idle;
                            r_po_spi_clk_out <= '1';
                        end if;
                    WHEN t_convert =>
                        spi_process_count <= spi_process_count + 1;
                        
                        --indicate sample and hold being ready
                        if spi_process_count = g_sh_counter_latch-1 then
                            so_sh_rdy <= '1';
                        else
                            so_sh_rdy <= '0';
                        end if;

                        spi_clk_div <= spi_clk_div + 1;
                        if spi_clk_div = g_u8_clk_cnt-2 then
                            spi_clk_div <= 0;
                            r_po_spi_clk_out <= not r_po_spi_clk_out;
                        end if;

                        if spi_clk_div = g_u8_clk_cnt/2 -1 then
                            r_po_spi_clk_out <= not r_po_spi_clk_out;
                            spi_rx_buffer <= spi_rx_buffer(16 downto 0) & pi_spi_serial;
                        end if;

                        st_ad_states <= t_convert;
                        so_spi_rdy <= '0';
                        if spi_process_count = g_u8_clk_cnt*g_u8_clks_per_conversion-g_u8_clk_cnt/2 - 1 then
                            st_ad_states <= t_idle;
                            b_spi_rx     <= spi_rx_buffer(16 downto 1);
                            so_spi_rdy   <= '1';
                        end if;

                    WHEN others =>
                        spi_clk_div <= 0;
                        spi_process_count <= 0;
                        i                <= (g_u8_clks_per_conversion)+1;
                        spi_rx_buffer    <= (others => '0');
                        r_po_spi_clk_out <= '1';
                        so_sh_rdy        <= '0';
                        so_spi_rdy       <= '0';
                        st_ad_states     <= t_calibrate;
                end CASE;

            else
                spi_clk_div <= 0;
                spi_process_count <= 0;
                i                <= (g_u8_clks_per_conversion)+1;
                spi_rx_buffer    <= (others => '0');
                r_po_spi_clk_out <= '1';
                so_sh_rdy        <= '0';
                so_spi_rdy       <= '0';
                st_ad_states     <= t_calibrate;
            end if;
        end if; --rising_edge
    end process spi_control;	

    po_spi_clk_out <= r_po_spi_clk_out;
    s_spi_busy     <= st_ad_states(1);
    po_spi_cs      <= NOT st_ad_states(1);

end ads_7056; --architecture
