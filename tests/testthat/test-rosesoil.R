test_that("rosesoil() works", {
  skip_if_not(py_module_available("rosetta"))
  skip_if(rosetta_pkg_version() < package_version("0.3.0"))
  skip_on_cran()

  res <- rosesoil(list(c(30, 30, 40, 1.5)))
  expect_true(inherits(res, "data.frame"))
  expect_true("thr" %in% colnames(res))
  expect_true("ths" %in% colnames(res))
  expect_true("k0" %in% colnames(res))
  expect_true("lpar" %in% colnames(res))
})

test_that("rosesoil() with data.frame and vars works", {
  skip_if_not(py_module_available("rosetta"))
  skip_if(rosetta_pkg_version() < package_version("0.3.0"))
  skip_on_cran()

  df <- data.frame(S = 30, Si = 30, C = 40, BD = 1.5)
  res <- rosesoil(df, vars = c("S", "Si", "C", "BD"))
  expect_true(inherits(res, "data.frame"))
  expect_true("thr" %in% colnames(res))
})
