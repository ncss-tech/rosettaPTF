library(reticulate)
library(rosettaPTF)

ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
PYENV_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/py_env"
PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"

use_python(PYEXE_PATH, required = TRUE)

options(reticulate.conda_binary = CONDA_PATH)

install_rosetta(envname = PYENV_PATH)
#> Fetching package metadata ...............
#> Solving package specifications:
#>
#>   InvalidSpecError: Invalid spec: =2.7
