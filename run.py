from pathlib import Path
from os.path import join
from vunit import VUnit
from glob import glob

# ROOT
ROOT = Path(__file__).resolve().parent

# Sources path for DUT
SRC_PATH = ROOT / "source" 
MATH_LIBRARY_PATH = "math_library"
SYSTEM_CONTROL_PATH = "system_control"

VU = VUnit.from_argv()

mathlib = VU.add_library("math_library")

lib = VU.add_library("lib")

## Possible single line VHDL source code detection with globbing 
## Uncomment all subsequent lines if glob is used

mathlib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "multiplier" / "*.vhd") 
VU.main()
