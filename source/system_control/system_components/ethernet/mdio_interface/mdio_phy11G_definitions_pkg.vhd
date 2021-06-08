library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package mdio_phy_11g_definitions_pkg is

    subtype mdio_word is std_logic_vector(15 downto 0);
    type phy_11g_mdio_registers is record
        CTRL     : mdio_word; -- Control
        STAT     : mdio_word; -- Status Register
        PHYID1   : mdio_word; -- PHY Identifier 1
        PHYID2   : mdio_word; -- PHY Identifier 2
        AN_ADV   : mdio_word; -- Auto-Negotiation Advertisement
        AN_LPA   : mdio_word; -- Auto-Negotiation Link-Partner Ability
        AN_EXP   : mdio_word; -- Auto-Negotiation Expansion
        AN_NPTX  : mdio_word; -- Auto-Negotiation Transmit Register
        AN_NPRX  : mdio_word; -- Auto-Negotiation Link-Partner Received
        GCTRL    : mdio_word; -- Gigabit Control Register
        GSTAT    : mdio_word; -- Gigabit Status Register
        RES11    : mdio_word; -- Reserved
        RES12    : mdio_word; -- Reserved
        MMDCTRL  : mdio_word; -- MMD Access Control Register
        MMDDATA  : mdio_word; -- MMD Access Data Register
        XSTAT    : mdio_word; -- Extended Status Register
        PHYPERF  : mdio_word; -- Physical Layer Performance Status
        PHYSTAT1 : mdio_word; -- Physical Layer Status 1
        PHYSTAT2 : mdio_word; -- Physical Layer Status 2
        PHYCTL1  : mdio_word; -- Physical Layer Control 1
        PHYCTL2  : mdio_word; -- Physical Layer Control 2
        ERRCNT   : mdio_word; -- Error Counter
        EECTRL   : mdio_word; -- EEPROM Control Regis ter
        MIICTRL  : mdio_word; -- Media-Independent Interface Control
        MIISTAT  : mdio_word; -- Media-Independent Interface Status
        IMASK    : mdio_word; -- Interrupt Mask Register
        ISTAT    : mdio_word; -- Interrupt Status Register
        LED      : mdio_word; -- LED Control Register
        TPGCTRL  : mdio_word; -- Test-Packet Generator Control
        TPGDATA  : mdio_word; -- Test-Packet Generator Data
        FWV      : mdio_word; -- Firmware Version Register
        RES1F    : mdio_word; -- Reserved
    end record;

------------------------------------------------------------------------
-------------------------- MDIO registers ------------------------------

    type CTRL_control_register is record
        -- reset value =x"9040"
        -- forced speed selection (msb,lsb) = 0 -> 10Mbit, 1 ->100mbit, 2 -> 1000mbit, 3 reserved
        RST : std_logic;
        Loop_Back : std_logic;
        forced_speed_selection_lsb : std_logic;
        auto_negotation_enable_1 : std_logic;
        power_down_1 : std_logic;
        isolate_phy_from_mac_1 : std_logic;
        restart_auto_negotiation_1 : std_logic;
        forced_duplex_mode_1_full_0_half : std_logic;
        collision_test_1_enable : std_logic;
        forced_speed_selection_msb : std_logic;
        reserved_5to0 : std_logic_vector(5 downto 0);
    end record;

    type STAT_status_register is record
        -- reset value x"7949"
        CBT4_ability_1_enabled                              : std_logic;
        CBTXF_1_100BTX_full_duplex_supported                : std_logic;
        CBTXH_1_100BTX_half_duplex_supported                : std_logic;
        XBTF_1_10BT_full_duplex_supported                   : std_logic;
        XBTH_1_10BT_half_duplex_supported                   : std_logic;
        CBT2F_1_100BT2_full_duplex_supported                : std_logic;
        CBT2H_1_100BT2_half_duplex_supported                : std_logic;
        EXT_1_extended_status_information_available         : std_logic;
        reserved                                            : std_logic;
        MFPS_1_management_frames_supported_without_preamble : std_logic;
        ANOK_1_auto_negotiation_completed                   : std_logic;
        remote_fault_1_detected                             : std_logic;
        ANAB_1_able_to_perform_auto_negotiation             : std_logic;
        LS_1_link_is_up                                     : std_logic;
        JD_1_jabber_condition_detected                      : std_logic;
        XCAP_1_extended_capability_registers_supported      : std_logic;
    end record;

    type PHYID1_phy_identifier1 is record
        -- reset x"D565"
        OUI_organizationally_unique_identifier_bits_3to18 : std_logic_vector(15 downto 0);
    end record;

    type PHYID2_phy_identifier2 is record
        -- reset x"A41"
        OUI_organizationally_unique_identifier_bits_19to24 : std_logic_vector(15 downto 10);
        LDN_lantiq_device_number : std_logic_vector(9 downto 4);
        LDNR_lantiq_device_number : std_logic_vector(3 downto 0);
    end record;

    type AN_ADV_auto_negotiation_advertisement is record
        -- x"01E1"
        NP_1_additional_next_pages_will_follow : std_logic;
        reserved : std_logic;
        RF_1_remote_fault_is_indicated : std_logic;
        TAF_advertise_technology_ability : std_logic_vector(12 downto 5);
        SF_00001_selects_IEEE802_3 : std_logic_vector(4 downto 0);
    end record;

    type AN_LPA_auto_negotiation_link_partner_ability is record
        -- reset x"0000"
        NP_1_additional_next_pages_will_follow          : std_logic;
        ACK_1_link_code_word_received                   : std_logic;
        RF_1_remote_fault_is_indicated_by_link_partner  : std_logic;
        TAF_link_partners_advertised_technology_ability : std_logic_vector(12 downto 5);
        SF_00001_selects_IEEE802_3                      : std_logic_vector(4 downto 0);
    end record;

    type AN_EXP_auto_neg_expansion is record
        -- reset x"0004"
        RESD_reserved                                     : std_logic_vector(15 downto 5);
        PDF_1_parallel_detection_detected_fault           : std_logic;
        LPNPC_1_link_partner_capable_exhanging_next_pages : std_logic;
        NPC_1_local_device_capable_exhanging_next_pages   : std_logic;
        PR_1_new_page_received                            : std_logic;
        LPANC_1_link_partner_autonegotiation_capable      : std_logic;
    end record;

    type AN_NPXT_auto_negot_next_page_transmit is record
        NP_1_additional_next_pages_will_follow : std_logic;
        RES_write_zero_ignore_read             : std_logic;
        MP_1_message_page_0_unformatted_page   : std_logic;
        ACK2_1_device_will_comply_with_message : std_logic;
        TOGG_toggle_1_when_previous_was_0      : std_logic;
        MCF_message_or_unformatted_code_field  : std_logic_vector(10 downto 0);
    end record;

    type AN_NPRX_auto_neg_link_partner_received is record
        -- reset "2001"
        NP_1_additional_next_pages_will_follow : std_logic;
        ACK_1_link_partners_link_code_received : std_logic;
        MP_1_message_page_0_unformatted_page : std_logic;
        ACK2_1_device_will_comply_with_message : std_logic;
        TOGG_toggle_1_when_previous_was_0 : std_logic;
        MCF_message_or_unformatted_code_field : std_logic_vector(10 downto 0);
    end record;

    type GCTRL_gigabit_control_register is record
        -- reset x"0300"
        TM_000_normal_operation                            : std_logic_vector(15 downto 13);
        MSEN_1_master_slave_manual_configuration           : std_logic;
        MS_1_configure_as_master_only_when_MSEN_1          : std_logic;
        MSPT_1_multi_port_device_type_0_single_port_device : std_logic;
        MBTFD_1_advertise_1000BT_full_duplex_capability    : std_logic;
        MBTHD_1_advertise_1000BT_HALF_duplex_capability    : std_logic;
        RES_write_as_zero_ignore_on_read                   : std_logic_vector(7 downto 0);
    end record;

    type GSTAT_gigabit_status_register is record
        -- reset x"0000"
        MSFAULT_0_masterslave_manual_configuration_ok : std_logic;
        MSRES_1_local_phy_configured_as_master        : std_logic;
        LRXSTAT_1_local_receiver_ok                   : std_logic;
        RRXSTAT_1_remote_receiver_ok                  : std_logic;
        MBTFD_link_partner_1000BT_full_duplex_capable : std_logic;
        MBTHD_link_partner_1000BT_HALF_duplex_capable : std_logic;
        RES_write_zero_ignore_read                    : std_logic_vector(9 downto 8);
        IEC_idle_error_count                          : std_logic_vector(7 downto 0);
    end record;

    type RES11_reserved_for_power_sourcing_equipment_not_supported is record
        -- reset x"0000"
        RES_write_zero_ignore_read : std_logic_vector(15 downto 0);
    end record;

    type RES12_reserved_for_power_sourcing_equipment_not_supported is record
        -- reset x"0000"
        RES_write_zero_ignore_read : std_logic_vector(15 downto 0);
    end record;

    type MMDCTRL_mmd_access_control_register is record
        -- reset x"0000"
        ACTYPE_access_type_function : std_logic_vector(15 downto 14);
        RESH_reserved_write_as_zero_ignore_on_read : std_logic_vector(13 downto 8);
        RESL_reserved_write_as_zero_ignore_on_read : std_logic_vector(7 downto 5);
        DEVAD_device_address_see_IEEE802_3_clause_45_2 : std_logic_vector(4 downto 0);
    end record;

    type MMDDATA_mmd_access_Data_register is record
        -- reset x"0000"
        ADDR_DATA_address_or_data_register : std_logic_vector(15 downto 0);
    end record;

    type XSTAT_extended_status_register is record
        -- reset x"3000"
        MBXF_1_phy_supports_1000BX_full_duplex : std_logic;
        MBXH_1_phy_supports_1000BX_HALF_duplex : std_logic;
        MVTF_1_phy_supports_1000BT_full_duplex : std_logic;
        MVTH_1_phy_supports_1000BT_HALF_duplex : std_logic;
        RESH_ignore_when_read : std_logic_vector(11 downto 8);
        RESL_ignore_when_read : std_logic_vector(7 downto 0);
    end record;

    type PHYPERF_physical_layer_performance_status is record
        FREQ_link_partner_frequency_offset_0x80_means_invalid : std_logic_vector(15 downto 8);
        SNR_receiver_snr_margin_in_dB : std_logic_vector(7 downto 4);
        LEN_estimated_loop_length : std_logic_vector(3 downto 0);
    end record;

    type PHYSTAT1_physical_layer_status_1 is record
        -- reset x"0000"
        RESH_reserved_write_as_zero_ignore_on_read : std_logic_vector(15 downto 9);
        LSADS_1_auto_downspeed_detected            : std_logic;
        POLD_1_polarity_inverted_on_portD          : std_logic;
        POLC_1_polarity_inverted_on_portC          : std_logic;
        POLB_1_polarity_inverted_on_portB          : std_logic;
        POLA_1_polarity_inverted_on_portA          : std_logic;
        MDICD_0_normal_MDI_mode_on_ports_CD        : std_logic;
        MDIAB_0_normal_MDI_mode_on_ports_AB        : std_logic;
        RESL_write_as_zero_ignore_on_read          : std_logic_vector(1 downto 0);
    end record;

    type PHYSTAT2_physica_status_2 is record
        -- reset x"0000"
        RESD_write_as_zero_ignore_on_read : std_logic;
        SKEWD_receive_skew_on_port_D      : std_logic_vector(14 downto 12);
        RESC_write_as_zero_ignore_on_read : std_logic;
        SKEWC_receive_skew_on_port_C      : std_logic_vector(10 downto 8);
        RESB_write_as_zero_ignore_on_read : std_logic;
        SKEWB_receive_skew_on_port_B      : std_logic_vector(6 downto 4);
        RESA_write_as_zero_ignore_on_read : std_logic;
        SKEWA_receive_skew_on_port_A      : std_logic_vector(2 downto 0);
    end record;

    type PHYCTL1_physical_layer_control_1 is record
        -- reset x"0001"
        TLOOP_test_loop_000_normal_operation     : std_logic_vector(15 downto 13);
        TXOFF_1_transmitter_is_off               : std_logic;
        TXADJ_transmit_amplitude_adjustment      : std_logic_vector(11 downto 8);
        POLD_1_transmit_polarity_inverted_port_D : std_logic;
        POLC_1_transmit_polarity_inverted_port_C : std_logic;
        POLB_1_transmit_polarity_inverted_port_B : std_logic;
        POLA_1_transmit_polarity_inverted_port_A : std_logic;
        MDICD_0_normal_MDI_mode_on_ports_CD      : std_logic;
        MDIAB_0_normal_MDI_mode_on_ports_AB      : std_logic;
        TXEEE10_0_10BT_amplitude_is_2V3          : std_logic;
        AMDIX_1_phy_performs_auto_MDI_or_MDIX    : std_logic;
    end record;

    type PHYCTL2_physical_layer_control2 is record
        -- reset x"8006"
        LSADS_00_do_not_perform_auto_downspeed            : std_logic_vector(15 downto 14);
        RESH_write_as_zero_ignore_when_read               : std_logic_vector(13 downto 11);
        CLKSEL_1_125MHZ_0_25MHZ_clockout_frequency        : std_logic;
        SDETP_signal_polarity_detection_0_LOWACTIVE_SIGDET_is_low_active : std_logic;
        STICKY_0_sticky_bit_handling_is_disabled          : std_logic;
        RESL_write_as_zero_ignore_on_readignore_when_read : std_logic_vector(7 downto 4);
        ADCR_0_default_adc_resolution_1_boosted           : std_logic;
        PSCL_0_power_scaling_based_on_link_quality_disabled : std_logic;
        ANPD_0_auto_negotiation_power_down_is_disabled : std_logic;
        LPI_0_disable_EEE_activation_when_connected_to_legacy_MAC : std_logic;
    end record;

    type ERRCNT_error_counter is record
        -- reset x"0000"
        RES_write_zero_ignore_read           : std_logic_vector(15 downto 12);
        SEL_configure_which_error_is_counted : std_logic_vector(11 downto 8);
        COUNT_counter_state                  : std_logic_vector(7 downto 0);
    end record;

    type EECTRL_eeprom_control_register is record
        EESCAN_0_eeprom_configuration_only_with_hardware_reset : std_logic;
        EEAF_0_no_access_error_detected                        : std_logic;
        CSRDET_0_configuration_signature_record_not_detected   : std_logic;
        EEDET_0_no_eeprom_detected                             : std_logic;
        SIZE_2_pow_kbit_value_eeprom_size_valid_0_to_10        : std_logic_vector(11 downto 8);
        ADRMODE_0_11bit_address_mode_1_16_bit                  : std_logic;
        DADR_eeprom_device_Address                             : std_logic_vector(6 downto 4);
        SPEED_100k_400k_1M_3M4_eeprom_clock_speed              : std_logic_vector(3 downto 3);
        RDWR_1_eeprom_write_access_0_read_access               : std_logic;
        EXEC_1_access_to_eeprom_currently_pending              : std_logic;
    end record;

    type MIICTRL_media_independent_interface_control is record
        -- reset x"8000"
        RXCOFF_1_rxclk_is_active_when_link_is_down  : std_logic;
        RXSKEW_rgmii_receive_timing_skew            : std_logic_vector(14 downto 12);
        V25_33_mii_is_operated_at_3v3_when_bit_is_0 : std_logic;
        TXSKEW_rgmii_transmit_timing_skew           : std_logic_vector(10 downto 8);
        CRS_sensitivity_configuration               : std_logic_vector(7 downto 6);
        FLOW_00_mac_interface_to_twisted_copper     : std_logic;
        MODE_0000_rgmii_mode                        : std_logic_vector(3 downto 0);
    end record;

    type MIISTAT_media_independent_interface_status is record
        RESH_write_as_zero_ignore_when_read                         : std_logic_vector(15 downto 8);
        PHY_00_twisted_pair_active_phy_interface                    : std_logic_vector(7 downto 6);
        PS_00_no_pause                                              : std_logic_vector(5 downto 4);
        DPX_1_mii_currently_at_full_duplex_mode                     : std_logic;
        EEE_0_energy_efficient_mode_disabled_after_auto_negotiation : std_logic;
        SPEED_00_10mit_01_100mbit_10_1000mbit_set_as_current_speed  : std_logic_vector(1 downto 0);
    end record;

    type IMASK_interrupt_mask_register is record
        -- reset x"0000"
        WOL_0_wake_on_lan_event_inactive            : std_logic;
        MSRE_0_master_slave_resolution_inactive     : std_logic;
        NPRX_0_next_page_receive_inactive           : std_logic;
        NPTX_0_next_page_transmitted_inactive       : std_logic;
        ANE_0_auto_negotiation_error_inactive       : std_logic;
        ANC_0_auto_negotiation_complete_inactive    : std_logic;
        RESH_write_as_zero_ignore_when_read         : std_logic;
        RESL_write_as_zero_ignore_on_read           : std_logic_vector(7 downto 6);
        ADSC_0_link_auto_downspeed_detect_inactive  : std_logic;
        MDIPC_0_mdi_polarity_change_detect_inactive : std_logic;
        MDIXC_0_mdix_change_detect_inactive         : std_logic;
        DXMC_0_duplex_mode_change_detect_inactive   : std_logic;
        LSPC_0_link_speed_change_detect_inactive    : std_logic;
        LSTC_0_link_state_change_detect_inactive    : std_logic;
    end record;

    type ISTAT_interrupt_status_register is record
        -- reset x"0000"
        WOL_0_wake_on_lan_event_masked_out            : std_logic;
        MSRE_0_master_slave_resolution_masked_out     : std_logic;
        NPRX_0_next_page_receive_masked_out           : std_logic;
        NPTX_0_next_page_transmitted_masked_out       : std_logic;
        ANE_0_auto_negotiation_error_masked_out       : std_logic;
        ANC_0_auto_negotiation_complete_masked_out    : std_logic;
        RESH_write_as_zero_ignore_when_read           : std_logic;
        RESL_write_as_zero_ignore_on_read             : std_logic_vector(7 downto 6);
        ADSC_0_link_auto_downspeed_detect_masked_out  : std_logic;
        MDIPC_0_mdi_polarity_change_detect_masked_out : std_logic;
        MDIXC_0_mdix_change_detect_masked_out         : std_logic;
        DXMC_0_duplex_mode_change_detect_masked_out   : std_logic;
        LSPC_0_link_speed_change_detect_masked_out    : std_logic;
        LSTC_0_link_state_change_detect_masked_out    : std_logic;
    end record;

    type LED_control_register is record
        -- reset x"0f00"
        RESH_write_as_zero_ignore_when_read     : std_logic_vector(15 downto 12);
        LED3EN_1_enable_integrated_led_function : std_logic;
        LED2EN_1_enable_integrated_led_function : std_logic;
        LED1EN_1_enable_integrated_led_function : std_logic;
        LED0EN_1_enable_integrated_led_function : std_logic;
        RESL_write_as_zero_ignore_on_read       : std_logic_vector(7 downto 4);
        LED3DA_1_switch_on_led3                 : std_logic;
        LED2DA_1_switch_on_led2                 : std_logic;
        LED1DA_1_switch_on_led1                 : std_logic;
        LED0DA_1_switch_on_led0                 : std_logic;
    end record;

    type TPGCTRL_test_packet_generator_control is record
        -- reset "0000"
        RESH_write_as_zero_ignore_when_read        : std_logic_vector(15 downto 14);
        MODE_1_send_single_packet                  : std_logic;
        RESH0_write_as_zero_ignore_when_read       : std_logic;
        IPGL_00_inter_packet_gap_length_is_48_bits : std_logic_vector(11 downto 10);
        TYPE_00_use_random_data_as_packet_data     : std_logic_vector(9 downto 8);
        RESL1_write_as_zero_ignore_on_read         : std_logic;
        SIZE_000_packet_length_is_64_bytes         : std_logic_vector(6 downto 4);
        RESL0_write_as_zero_ignore_on_read         : std_logic_vector(3 downto 2);
        START_1_starts_test_packet_generation      : std_logic;
        EN_0_disables_test_packet_generation       : std_logic;
    end record;

    type TPGDATA_test_packet_generator_data is record
        -- reset x"00aa"
        DA_destination_address      : std_logic_vector(15 downto 12);
        SA_source_address           : std_logic_vector(11 downto 8);
        DATA_byte_to_be_transmitted : std_logic_vector(7 downto 0);
    end record;

    type FWV_firmware_version_register is record
        REL_1_indicates_release_version : std_logic;
        MAJOR_major_version_number      : std_logic_vector(14 downto 8);
        MINOR_minor_version_number      : std_logic_vector(7 downto 0);
    end record;

    type RES1F_reserved_for_future_use is record
        RES_write_zero_ignore_read : std_logic_vector(15 downto 0);
    end record;

------------------------------------------------------------------------
----- MMD register addressable indirectly through MDCTRL and MMDATA ----

    type EEE_CTRL1_eee_control_register is record
        RESH_write_as_zero_ignore_on_read : std_logic_vector(15 downto 11);
        RXCKST_1_phy_can_stop_mii_clock_during_low_power_mode : std_logic_vector(10 downto 10);
        RESL_write_as_zero_ignore_on_read : std_logic_vector(9 downto 0);
    end record;

    type EEE_STAT1_eee_status_register_1 is record
        RESH_write_as_zero_ignore_on_read                 : std_logic_vector(15 downto 12);
        TXLPI_RCVD_0_tx_lpi_not_received                  : std_logic_vector(11 downto 11);
        RXLPI_RCVD_0_rx_lpi_not_received                  : std_logic_vector(10 downto 10);
        TXLPI_IND_0_tx_lpi_inactive                       : std_logic_vector(9 downto 9);
        RXLPI_IND_0_rx_lpi_inactive                       : std_logic_vector(8 downto 8);
        RES_write_as_zero_ignore_on_read                  : std_logic_vector(7 downto 7);
        RXCKST_0_phy_is_not_able_to_accept_stopped_clocks : std_logic_vector(6 downto 6);
        RESL_write_as_zero_ignore_on_read                 : std_logic_vector(5 downto 0);
    end record;

    type EEE_capability_Register is record
        -- reset x"0006"
        res1 : std_logic_vector(15 downto 7);
        EEE_10GBKR_0_phy_mode_not_supported : std_logic;
        EEE_10GBKX4_0_phy_mode_not_supported : std_logic;
        EEE_1000BKX_0_phy_mode_not_supported : std_logic;
        EEE_10GB_0_phy_mode_not_supportedT : std_logic;
        EEE_1000BT_0_phy_mode_not_supported : std_logic;
        EEE_100BTX_0_phy_mode_not_supported : std_logic;
        res0 : std_logic;
    end record;

    type EEE_WAKERR_wake_time_fault_count is record
        ERRCNT : std_logic_vector(15 downto 0);
    end record;

    type ANEG_stardard_auto_negotiation_register is record
        res1 : std_logic_vector(15 downto 7);
        EEE_10GBKR_0_phy_mode_not_supported  : std_logic;
        EEE_10GBKX4_0_phy_mode_not_supported : std_logic;
        EEE_1000BKX_0_phy_mode_not_supported : std_logic;
        EEE_10GB_0_phy_mode_not_supported    : std_logic;
        EEE_1000BT_0_phy_mode_not_supported  : std_logic;
        EEE_100BTX_0_phy_mode_not_supported  : std_logic;
        res0 : std_logic;
    end record;

    type EE_AN_ADV_auto_negotiation_advertisement is record
        res1 : std_logic_vector(15 downto 7);
        EEE_10GBKR_0_phy_mode_not_supported  : std_logic;
        EEE_10GBKX4_0_phy_mode_not_supported : std_logic;
        EEE_1000BKX_0_phy_mode_not_supported : std_logic;
        EEE_10GB_0_phy_mode_not_supported    : std_logic;
        EEE_1000BT_0_phy_mode_not_supported  : std_logic;
        EEE_100BTX_0_phy_mode_not_supported  : std_logic;
        res0 : std_logic;
    end record;

    type EE_AN_LPADV_auto_negotiation_link_partner_advertisement is record
        res1 : std_logic_vector(15 downto 7);
        EEE_10GBKR_0_phy_mode_not_supported  : std_logic;
        EEE_10GBKX4_0_phy_mode_not_supported : std_logic;
        EEE_1000BKX_0_phy_mode_not_supported : std_logic;
        EEE_10GB_0_phy_mode_not_supported    : std_logic;
        EEE_1000BT_0_phy_mode_not_supported  : std_logic;
        EEE_100BTX_0_phy_mode_not_supported  : std_logic;
        res0 : std_logic;
    end record;

    type EEPROM_address_space is record
        res : std_logic_vector(15 downto 8);
        EEPROM_memory : std_logic_vector(7 downto 0);
    end record;

    type LEDCH_led_configuration is record
        reserved                           : std_logic_vector(15 downto 8);
        FBF_00_2_hz_blinking_in_fast_mode  : std_logic_vector(7 downto 6);
        SBF_00_2_hz_blinking_in_slow_mode  : std_logic_vector(5 downto 4);
        reserved_1                         : std_logic_vector(3 downto 3);
        NACS_000_complex_function_disabled : std_logic_vector(2 downto 0);
    end record;

    type LEDCL_led_configuration is record
        reserved                                       : std_logic_vector(15 downto 8);
        SCAN_defines_which_complex_function_is_enabled : std_logic_vector(6 downto 4);
        reserved1                                      : std_logic_vector(3 downto 3);
        CBLINK_complex_blinking_configurattion         : std_logic_vector(2 downto 0);
    end record;

    type LED3H_configuration_for_led3 is record
        reserved                           : std_logic_vector(15 downto 8);
        CON_constant_on_field              : std_logic_vector(7 downto 4);
        BLINKF_fast_blinking_configuration : std_logic_vector(3 downto 0);
    end record;

    type LED2H_configuration_for_led2 is record
        reserved                           : std_logic_vector(15 downto 8);
        CON_constant_on_field              : std_logic_vector(7 downto 4);
        BLINKF_fast_blinking_configuration : std_logic_vector(3 downto 0);
    end record;

    type LED1H_configuration_for_led1 is record
        reserved                           : std_logic_vector(15 downto 8);
        CON_constant_on_field              : std_logic_vector(7 downto 4);
        BLINKF_fast_blinking_configuration : std_logic_vector(3 downto 0);
    end record;

    type LED0H_configuration_for_led0 is record
        reserved                           : std_logic_vector(15 downto 8);
        CON_constant_on_field              : std_logic_vector(7 downto 4);
        BLINKF_fast_blinking_configuration : std_logic_vector(3 downto 0);
    end record;

    type EEE_RXERR_LINK_FAIL_H is record
        data : std_logic;
    end record;

    type EEE_RXERR_LINK_FAIL_L is record
        data : std_logic;
    end record;

    type MII2CTRL is record
        data : std_logic;
    end record;

    type LEG_LPI_CFG0 is record
        data : std_logic;
    end record;

    type LEG_LPI_CFG1 is record
        data : std_logic;
    end record;
    --- wake on lan addres bytes 0 to 4

    type LEG_LPI_CFG2 is record
        data : std_logic;
    end record;

    type LEG_LPI_CFG3 is record
        data : std_logic;
    end record;


end package mdio_phy_11g_definitions_pkg;
