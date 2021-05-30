rem simulate spi_sar_adc.vhd
echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
ghdl -a --ieee=synopsys ..\spi_sar_adc_pkg.vhd
ghdl -a --ieee=synopsys ..\ads7056_driver.vhd
ghdl -a --ieee=synopsys tb_spi_sar_adc.vhd
ghdl -e --ieee=synopsys tb_spi_sar_adc
ghdl -r --ieee=synopsys tb_spi_sar_adc --vcd=tb_spi_sar_adc.vcd


IF %1 EQU 1 start "" gtkwave tb_spi_sar_adc.vcd
