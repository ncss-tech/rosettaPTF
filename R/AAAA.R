rosetta_module <- NULL

#' @importFrom reticulate import
.onLoad <- function(libname, pkgname) {
  # delay load rosetta module (will only be loaded when accessed via $)
  rosetta_module <<- reticulate::import("rosetta", delay_load = TRUE)
}
