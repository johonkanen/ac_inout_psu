rem simulate spi.vhd
echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

rem ghdl -a --ieee=synopsys ..\spi_pkg.vhd
rem ghdl -a --ieee=synopsys ..\spi.vhd
ghdl -a --ieee=synopsys %source%/spi/spi_pkg.vhd
ghdl -a --ieee=synopsys %source%/spi/spi_adc_pkg.vhd
ghdl -a --ieee=synopsys tb_spi.vhd
ghdl -e --ieee=synopsys tb_spi
ghdl -r --ieee=synopsys tb_spi --vcd=tb_spi.vcd


IF %1 EQU 1 start "" gtkwave tb_spi.vcd
