echo off
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)

cd %project_root%\source\math_library\sincos\sincos_simulation\
call sim_sincos.bat 0 1 

cd %project_root%\source\math_library\division\division_simulation\
call sim_integer_division.bat 0 1

