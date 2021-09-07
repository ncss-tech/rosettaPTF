test_that("rosetta-soil module can be installed", {
  skip_if_not(py_module_available("numpy"))

  # rosetta may be available
  avail <- rosetta_module_available()

  # install rosetta (does not fail if already installed)
  cat("\n\n")

  # use pip (if available) or use ArcGIS Pro Conda environment (if available)
  res <- try(install_rosetta(pip = TRUE, arcpy_path = "C:/Program Files/ArcGIS/Pro/bin/Python/"))

  if (inherits(res, 'try-error'))
    skip("Unable to install")
  cat("\n\n")

  # res is TRUE if both rosetta-soil and numpy have been imported / can be loaded
  expect_true(res)

  # note with a skip when we didn't install something new
  if (avail) {
    skip('rosetta-soil module was already installed')
  }

})

test_that("rosetta-soil module is available", {

  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))

  # should be available
  avail <- rosetta_module_available()
  expect_true(avail)
})
