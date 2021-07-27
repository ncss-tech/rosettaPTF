#' Heuristics to Find Python
#'
#' If you are using the {rosettaPTF} package for the first time you will need to have Python installed to obtain the necessary modules. You can set up {reticulate} to install into a virtual or Conda environment. Usually {reticulate} should cover most or all of the setup.
#'
#' This method wraps `reticulate::py_discover_config()` and `reticulate::use_python()`; it provides several heuristics for setting up {reticulate} to use Python in commonly installed locations.
#'
#' @param arcpy_path Optional: Path to ArcGIS Pro Python installation. For example: `"C:/Program Files/ArcGIS/Pro/bin/Python"`. Set as `NULL` to prevent use of ArcGIS Pro instance.
#'
#'@details
#' If you have Python set up correctly you should be able to run `reticulate::py_config()` or `reticulate::py_discover_config()` and discover your shared library.
#'
#' A common problem with {reticulate} is not pointing at the correct (or any) `python` binary or `libpython` shared library. Use `reticulate::use_python("/path/to/python", required = TRUE)` to set the path or, alternately, be sure `python` can be found on your PATH. {reticulate} has a preference for Python environments that have `numpy` installed.
#'
#' ### Windows / Miniconda
#'
#' Use `reticulate::install_miniconda()` if you'd like to install a Miniconda Python environment. Conda is default on Windows.
#'
#' For devices with limited ability to install new software that have ArcGIS Pro installed (some USDA computers), this method can look for a Python installation in `"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"` and Conda executable in `"C:/Program Files/ArcGIS/Pro/bin/Python/Scripts"`. The base file path to "Python" directory can be customized using the `arcpy_path` argument.
#'
#' ### Linux and OS X
#'
#' On Linux and OS X you can create a virtual environment using `reticulate::virtualenv_create()`. The default environment name will be `"r-reticulate"`.
#'
#' @return character path to `python` or `NULL` if no suitable environment can be found. The result is stored as the package option `rosettaPTF.python_path`.
#'
#' @export
#'
#' @examples
#'
#' find_python()
#'
#' @importFrom reticulate py_config py_discover_config use_python use_condaenv conda_binary
find_python <- function(arcpy_path = getOption("rosettaPTF.arcpy_path")) {

  pypath_before <- getOption("rosettaPTF.python_path")

  if (is.null(pypath_before)) {

    pypath <- try(.find_python(pypath = pypath_before, arcpy_path = arcpy_path))

    if (!inherits(pypath, 'try-error')){
      options(rosettaPTF.python_path = pypath)
    }

  }

  getOption("rosettaPTF.python_path")
}

.find_python <- function(pypath = getOption("rosettaPTF.python_path"),
                         arcpy_path = getOption("rosettaPTF.arcpy_path")) {

  # check for ArcPro environment python EXE, and use it if present (USDA non-privileged machines)
  ARCPY_PATH <- file.path(arcpy_path, "envs/arcgispro-py3")
  PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
  CONDA_PATH <- file.path(arcpy_path, "Scripts/conda.exe")

  res <- NULL

  # if ArcGIS Pro is installed
  if (length(PYEXE_PATH) > 0 && file.exists(PYEXE_PATH)) {

    message("\n\nUsing ArcGIS Pro conda environment/python.exe\n\n")

    res <- try( {
      subres <- reticulate::use_python(PYEXE_PATH, required = TRUE)
      reticulate::use_condaenv(ARCPY_PATH)

      options(reticulate.conda_binary = CONDA_PATH)
      options(rosettaPTF.python_path = PYEXE_PATH)
      options(rosettaPTF.arcpy_path = arcpy_path)

      subres
    }, silent = TRUE)

  # user specified python
  } else if (length(pypath) > 0 && file.exists(pypath)) {

    res <- try(reticulate::use_python(pypath, required = TRUE), silent = TRUE)

  # other cases of Conda or virtualenv
  } else {

    # python path from py_discover_config() result
    res <- reticulate::py_discover_config()
    res <- try(reticulate::use_python(res[["python"]], required = TRUE), silent = TRUE)

  }

  if (inherits(res, 'try-error')) {
    stop(res, call. = FALSE)
  }

  res
}
