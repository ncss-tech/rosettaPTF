test_that("run_rosetta() works", {
  res <- run_rosetta(list(c(30, 30, 40, 1.5), c(55, 25, 20),  c(55, 25, 20, 1.1)),
                     rosetta_version = 3)
  expect_true(inherits(res, 'data.frame'))
})
