test_that("prediction with Rosetta class works", {

  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))

  one <- predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
  two <- ann_predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))

  expect_true(inherits(one, 'list') && inherits(two, 'list'))
})
