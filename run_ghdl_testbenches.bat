echo off
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
cd %project_root%\source\math_library\multiplier\simulation\
call sim_multiplier.bat 0

cd %project_root%\source\math_library\power_supply_model\power_supply_model_simulation\
call sim_power_supply_model.bat 0 

cd %project_root%\source\math_library\lcr_filter_model\lcr_filter_simulation\
call sim_lcr_filter.bat 0

cd %project_root%\source\math_library\inverter_model\inverter_model_simulation\
call sim_inverter_model.bat 0

cd %project_root%\source\math_library\division\division_simulation\
call sim_integer_division.bat 0 0

cd %project_root%\source\math_library\division\division_simulation\
call sim_nr_iterator.bat 0

cd %project_root%\source\math_library\pi_controller\pi_controller_simulation\
call sim_pi_controller.bat 0

cd %project_root%\source\math_library\grid_inverter_control\simulate_grid_inverter_control\
call sim_grid_inverter_control.bat 0 1 

cd %project_root%\source\math_library\sincos\sincos_simulation\
call sim_sincos.bat 0 1 

