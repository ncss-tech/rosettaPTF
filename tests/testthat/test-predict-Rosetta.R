test_that("prediction with Rosetta class works", {

  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))

  one <- predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
  expect_warning({ two <- ann_predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1))) })

  expect_true(inherits(one, 'list') && inherits(two, 'list'))
  expect_true("mean" %in% names(one))
  expect_true("stdev" %in% names(one))
})

test_that("UnsaturatedK works", {
  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))
  skip_if(rosetta_pkg_version() < package_version("0.3.0"))

  uk <- UnsaturatedK()
  res <- predict(uk, list(c(0.12, 0.42, 0.008, 1.29)))
  expect_true(inherits(res, "data.frame"))
  expect_true("log10_K0_mean" %in% colnames(res))
})
