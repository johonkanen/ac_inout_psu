rem simulate uart_transreceiver.vhd
echo off

FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_tx/uart_tx.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
            ghdl -a --ieee=synopsys %source%/system_control/system_components/uart/uart_transreceiver/uart_rx/uart_rx.vhd
ghdl -a --ieee=synopsys ..\uart_transreceiver_pkg.vhd
ghdl -a --ieee=synopsys ..\uart_transreceiver.vhd
ghdl -a --ieee=synopsys tb_uart_transreceiver.vhd
ghdl -e --ieee=synopsys tb_uart_transreceiver
ghdl -r --ieee=synopsys tb_uart_transreceiver --vcd=tb_uart_transreceiver.vcd


IF %1 EQU 1 start "" gtkwave tb_uart_transreceiver.vcd
