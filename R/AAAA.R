rosetta_module <- NULL
numpy_module <- NULL

.install_python_message <- function() message("Python was not found on this system.\nTry setting the path manually with `options(rosettaPTF.python_path='/path/to/python')` or `options(rosettaPTF.arcpy_path='C:/path/to/ArcPro/Python')`")

#' @importFrom reticulate import py_available use_python
.loadModules <-  function() {

  # sometimes finds unsuitable python instance
  pypath <- find_python()

  if (!reticulate::py_available() && is.null(pypath)) {
    .install_python_message()
  }

  # delay load modules (will be loaded when accessed via $)
  if (is.null(rosetta_module)) {
    try(rosetta_module <<- reticulate::import("rosetta", delay_load = TRUE), silent = TRUE)
  }

  if (is.null(numpy_module)) {
    try(numpy_module <<- reticulate::import('numpy', delay_load = TRUE), silent = TRUE)
  }

  !is.null(rosetta_module) && !is.null(numpy_module)

}

#' @importFrom reticulate configure_environment
.onLoad <- function(libname, pkgname) {
  # rosettaPTF.arcpy_path Path to ArcGIS Pro Python installation
  # Default: `"C:/Program Files/ArcGIS/Pro/bin/Python"`.
  # Set as `NULL` to prevent use of ArcGIS Pro instance.
  options(rosettaPTF.arcpy_path = "C:/Program Files/ArcGIS/Pro/bin/Python")
  # TODO: is configure_environment needed?
  # if (reticulate::configure_environment(pkgname)) {
    .loadModules()
  # }

}
