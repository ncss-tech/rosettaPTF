test_that("rosetta is available", {
  avail <- reticulate::py_module_available("rosetta")
  skip_if_not(avail)
  expect_true(avail)
})
