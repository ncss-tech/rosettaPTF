rosetta_module <- NULL
numpy_module <- NULL

#' @importFrom reticulate import py_available use_python
.loadModules <-  function() {

  pypath <- find_python()

  if (!reticulate::py_available() && is.null(pypath)) {
    message("Python was not found on this system.\nTry setting the path manually with `options(rosettaPTF.python_path='/path/to/python')`")
  }

  # delay load modules (will be loaded when accessed via $)
  if (is.null(rosetta_module)) {
    rosetta_module <<- reticulate::import("rosetta", delay_load = TRUE)
  }

  if (is.null(numpy_module)) {
    numpy_module <<- reticulate::import('numpy', delay_load = TRUE)
  }

  !is.null(rosetta_module) && !is.null(numpy_module)

}

#' @importFrom reticulate configure_environment
.onLoad <- function(libname, pkgname) {

  # TODO: is configure_environment needed?
  if (reticulate::configure_environment(pkgname)) {
    .loadModules()
  }

}
