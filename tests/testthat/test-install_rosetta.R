test_that("rosetta module is available", {
  avail <- rosetta_module_available()
  skip_if_not(avail)
  expect_true(avail)
})
