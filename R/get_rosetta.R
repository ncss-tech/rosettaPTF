#' Get rosetta instance
#'
#' @return An R object wrapping a Python module. Module attributes can be accessed via the `$` operator, or via `py_get_attr()`.
#' @export
get_rosetta_module <- function() {
  rosetta_module
}
