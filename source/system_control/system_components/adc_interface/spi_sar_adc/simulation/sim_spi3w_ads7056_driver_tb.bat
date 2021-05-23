rem simulate spi3w_ads7056.vhd
rem simulate uart.vhd
echo off
echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
set source=%project_root%/source

ghdl -a --std=08 --ieee=synopsys tb_spi3w_ads7056.vhd
ghdl -e --std=08 --ieee=synopsys tb_spi3w_ads7056
ghdl -r --std=08 --ieee=synopsys tb_spi3w_ads7056 --vcd=tb_spi3w_ads7056.vcd


IF %1 EQU 1 start "" gtkwave tb_spi3w_ads7056.vcd
