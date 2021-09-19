rem simulate uart_tx.vhd
echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
ghdl -a --ieee=synopsys ..\uart_tx_pkg.vhd
ghdl -a --ieee=synopsys ..\uart_tx.vhd
ghdl -a --ieee=synopsys tb_uart_tx.vhd
ghdl -e --ieee=synopsys tb_uart_tx
ghdl -r --ieee=synopsys tb_uart_tx --vcd=tb_uart_tx.vcd


IF %1 EQU 1 start "" gtkwave tb_uart_tx.vcd
