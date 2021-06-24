test_that("rosetta module is available", {

  # check for ArcPro environment python EXE, and use it if present (USDA CCE machines)
  ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
  PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
  CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"

  if (file.exists(PYEXE_PATH)) {
    message("\n\nUsing ArcGIS Pro conda environment/python.exe for testing...\n\n")
    reticulate::use_python(PYEXE_PATH, required = TRUE)
    reticulate::use_condaenv(ARCPY_PATH)
    options(reticulate.conda_binary = CONDA_PATH)
  }

  # install rosetta if needed
  if (!rosetta_module_available()) {
    install_rosetta(pip = TRUE)
  }

  # should be available
  avail <- rosetta_module_available()
  expect_true(avail)
})
