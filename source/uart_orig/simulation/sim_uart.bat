rem simulate uart.vhd
echo off
echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
set source=%project_root%/source
        ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_tx.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_rx.vhd
        ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_transreceiver.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_pkg.vhd
    ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart.vhd

ghdl -a --ieee=synopsys tb_uart.vhd
ghdl -e --ieee=synopsys tb_uart
ghdl -r --ieee=synopsys tb_uart --vcd=tb_uart.vcd


IF %1 EQU 1 start "" gtkwave tb_uart.vcd
