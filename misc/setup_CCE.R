library(reticulate)

# this sets up ArcGIS Pro python3 and conda environment for rosetta-soil

ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"

if (file.exists(PYEXE_PATH)) {
  reticulate::use_python(PYEXE_PATH, required = TRUE)
  reticulate::use_condaenv(ARCPY_PATH)
  options(reticulate.conda_binary = CONDA_PATH)
}
