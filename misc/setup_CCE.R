# library(reticulate)
#
# # this sets up ArcGIS Pro python3 and conda environment for rosetta-soil
#
# ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
# PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
# CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"
#
# if (file.exists(PYEXE_PATH)) {
#   reticulate::use_condaenv(ARCPY_PATH)
#   reticulate::use_python(python = PYEXE_PATH, required = TRUE)
#   options(reticulate.conda_binary = CONDA_PATH)
# }

library(reticulate)

x <- py_discover_config("rosetta")
if (length(x$python_versions) > 0) {
  idx <- which.max(order(sapply(x$python_versions, \(x) gsub("Python ", "", system(paste(shQuote(x), "--version"), intern = TRUE)))))
  use_python(x$python_versions[idx])
  py_config()
}

x <- py_discover_config()#("rosetta")
if (length(x$python_versions) > 0) {
  idx <- which.max(order(sapply(x$python_versions, \(x) gsub("Python ", "", system(paste(shQuote(x), "--version"), intern = TRUE)[1]))))
  use_python(x$python_versions[idx])
  py_config()
}

