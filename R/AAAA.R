rosetta_module <- NULL
numpy_module <- NULL

#' @importFrom reticulate import
.loadModules <-  function() {
  # delay load modules (will only be loaded when accessed via $)
  rosetta_module <<- reticulate::import("rosetta", delay_load = TRUE)
  numpy_module <<- reticulate::import('numpy', delay_load = TRUE)
}

.onLoad <- function(libname, pkgname) {
  .loadModules()
}
