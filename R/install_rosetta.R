#' Install Rosetta Python package
#'
#' Wrapper around `reticulate::py_install()` to install the Rosetta Pedotransfer Function Python package
#'
#' @param envname The name, or full path, of the environment in which Python packages are to be installed. When `NULL` (default), the active environment (`RETICULATE_PYTHON_ENV` variable) will be used; if that is unset, then the `"r-reticulate"` environment will be used.
#' @param method `"auto"`, `"virtualenv"`, or `"conda"`; Default: `"auto"`
#' @param conda Default: `"auto"`
#' @param pip _logical_. Use `pip` for package installation? Default: `TRUE`. This is only relevant when Conda environments are used, as otherwise packages will be installed from the Conda repositories.
#' @param system _logical_. Default: `FALSE`. If `TRUE`, try installing to system (user) site library with `system()` and set reticulate to use system Python.
#' @param user _logical_. Default: `FALSE`. Pass `--user` flag. This should only be done if other installation methods fail and it is impossible to use a virtual environment.
#' @param upgrade _logical_. Install latest versions of Python packages by passing `--upgrade` flag? Default: `TRUE`.
#' @param arcpy_path Argument passed to `find_python()`. Path to ArcGIS Pro Python installation e.g. ``. Set as `NULL` (default) to prevent use of ArcGIS Pro instance.
#'
#' @details From `reticulate::py_install()`: On Linux and OS X the "virtualenv" method will be used by default ("conda" will be used if virtualenv isn't available). On Windows, the "conda" method is always used.
#'
#' @export
#'
#' @importFrom reticulate py_install
#'
install_rosetta <- function(envname = NULL,
                            method = "auto",
                            conda = "auto",
                            pip = TRUE,
                            user = FALSE,
                            upgrade = TRUE,
                            system = FALSE,
                            arcpy_path = getOption("rosettaPTF.arcpy_path")) {

  # use heuristics to find python executable
  if (!is.null(arcpy_path) && dir.exists(arcpy_path)) {
    find_python(envname = envname, arcpy_path = arcpy_path)
  }

  if (!is.null(arcpy_path) && dir.exists(arcpy_path)) {
    p <- find_python(envname = envname, arcpy_path = arcpy_path)
    system <- TRUE
  } else {
    p <- Sys.which("python")
  }

  if (isFALSE(system)) {
    # get rosetta-soil (and numpy if needed)
    try(reticulate::py_install("rosetta-soil", envname = envname, method = method,
                               conda = conda, pip = pip, pip_options = c(ifelse(user, "--user", character()),
                                                                         ifelse(upgrade, "--upgrade", character()))), silent = TRUE)
  } else {
    reticulate::use_python(p, required = TRUE)
    try(system(paste(shQuote(p), "-m pip install", ifelse(upgrade, "--upgrade", ""),
                                                   ifelse(user, "--user", ""), "rosetta-soil")), silent = TRUE)
  }

  # load modules globally in package (prevents having to reload rosettaPTF library in session)
  .loadModules()

}
