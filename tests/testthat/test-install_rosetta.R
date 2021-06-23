test_that("rosetta is available", {
  skip_if_not(reticulate::py_module_available("rosetta"))
  # test code here...
  expect_true(FALSE)
})
