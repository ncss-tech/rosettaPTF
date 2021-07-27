#' Install Rosetta Python package
#'
#' Wrapper around `reticulate::py_install()` to install the Rosetta Pedotransfer Function Python package
#'
#' @param envname The name, or full path, of the environment in which Python packages are to be installed. When `NULL` (default), the active environment (`RETICULATE_PYTHON_ENV` variable) will be used; if that is unset, then the `"r-reticulate"` environment will be used.
#' @param method `"auto"`, `"virtualenv"`, or `"conda"`; Default: `"auto"`
#' @param conda Default: `"auto"`
#' @param pip _logical_. Use `pip` for package installation? Default: `TRUE`. This is only relevant when Conda environments are used, as otherwise packages will be installed from the Conda repositories.
#' @param arcpy_path Argument passed to `find_python()`. Path to ArcGIS Pro Python installation e.g. ``. Set as `NULL` (default) to prevent use of ArcGIS Pro instance.
#' @details From `reticulate::py_install()`: On Linux and OS X the "virtualenv" method will be used by default ("conda" will be used if virtualenv isn't available). On Windows, the "conda" method is always used.
#'
#' @export
#'
#' @importFrom reticulate py_install py_discover_config
#'
install_rosetta <- function(envname = NULL,
                            method = "auto",
                            conda = "auto",
                            pip = TRUE,
                            arcpy_path = getOption("rosettaPTF.arcpy_path")) {
  pypath <- NULL

  # use heuristics to find python executable
  if (!is.null(arcpy_path)){
    pypath <- arcpy_path
  } else {
    pypath <- find_python(arcpy_path = arcpy_path)
  }

  if (!is.null(pypath)) {

    # get rosetta-soil (and numpy if needed)
    reticulate::py_install("rosetta-soil", envname = envname, method = method, conda = conda, pip = pip)

    # load modules globally in package (prevents having to reload rosettaPTF library in session)
    .loadModules()
  } else {
    message("Skipping install")
  }

}
