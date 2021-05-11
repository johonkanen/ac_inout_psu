
# TODO, create script for dynamically assigning io locations

#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {pll_input_clock} -period 31.25 -waveform { 0.000 15.625 } [get_ports {pll_input_clock}]
#create_clock -name {ethernet_clock_125MHz} -period 8.000 -waveform { 0.000 4.000 } [get_ports {ethernet_clock_125MHz}]


#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks -create_base_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from * -to [get_ports *uart_tx*]
#set_false_path -from * -to [get_ports *switch*]
#set_false_path -from *u_power_supply_control|master_carrier[*] -to *ad_mux*
#set_false_path -from *u_power_supply_control|master_carrier[*] -to *triggers*

#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
