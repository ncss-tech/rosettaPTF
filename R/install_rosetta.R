#' Install Rosetta Python package
#'
#' Wrapper around `reticulate::py_install()` to install the Rosetta Pedotransfer Function Python package
#' @param envname The name, or full path, of the environment in which Python packages are to be installed. When `NULL` (the default), the active environment as set by the `RETICULATE_PYTHON_ENV` variable will be used; if that is unset, then the `"r-reticulate"` environment will be used.
#' @param method `"auto"`, `"virtualenv"`, or `"conda"`; Default: `"auto"`
#' @param conda Default: `"auto"`
#'
#' @export
#' @importFrom reticulate py_install
install_rosetta <- function(envname = NULL, method = "auto", conda = "auto") {
  reticulate::py_install("rosetta-soil", envname = envname, method = method, conda = conda)
}
