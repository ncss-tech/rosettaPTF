test_that("run_rosetta() with sample data", {
  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))
  skip_on_cran()

  data("MUKEY_PROP")
  varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
  res <- run_rosetta(MUKEY_PROP[1:10, varnames], rosetta_version = 3)

  expect_true(inherits(res, 'data.frame'))
  if (rosetta_pkg_version() >= package_version("0.3.0")) {
    expect_true(ncol(res) >= 15)
    expect_true("log10_K0_mean" %in% colnames(res))
  } else {
    expect_true(ncol(res) == 12)
  }
})

test_that("estimate_type argument with sample data", {
  skip_if_not(py_module_available("rosetta"))
  skip_if(rosetta_pkg_version() < package_version("0.3.0"))
  skip_on_cran()

  data("MUKEY_PROP")
  varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")

  res_log <- run_rosetta(MUKEY_PROP[1:5, varnames], estimate_type = "log")
  expect_true("log10_Ksat_mean" %in% colnames(res_log))

  res_lin <- run_rosetta(MUKEY_PROP[1:5, varnames], estimate_type = "arith")
  expect_true("ksat_mean" %in% colnames(res_lin))
  expect_false("log10_Ksat_mean" %in% colnames(res_lin))

  res_geo <- run_rosetta(MUKEY_PROP[1:5, varnames], estimate_type = "geo")
  expect_true("ksat_mean" %in% colnames(res_geo))
})

test_that("data.frame interface", {
  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))
  skip_on_cran()

  # Default column order with sample data
  data("MUKEY_PROP")
  varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
  res1 <- run_rosetta(MUKEY_PROP[1:5, varnames])
  expect_true(inherits(res1, 'data.frame'))

  # Custom column order with synthetic data
  res2 <- run_rosetta(data.frame(
    d = c(NA, 1.5),
    b = 60,
    a = 20,
    c = 20
  ), vars = letters[1:4])
  expect_true(inherits(res2, 'data.frame'))
})

test_that("run on SSURGO data", {
  skip_if_not(py_module_available("numpy"))
  skip_if_not(py_module_available("rosetta"))
  skip_on_cran()

  data("MUKEY_WCS", package = "rosettaPTF")
  res <- terra::rast(MUKEY_WCS, crs = "EPSG:5070")
  terra::ext(res) <- c(-1365495, -1358925, 2869245, 2873655)
  names(res) <- "mukey"

  mukeys <- as.numeric(terra::values(res[[1]]))
  umukeys <- unique(mukeys)
  varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
  levels(res) <- data.frame(mukey = umukeys, ID = seq_along(umukeys))

  data("MUKEY_PROP", package = "rosettaPTF")
  resprop <- MUKEY_PROP[, c("mukey", varnames)]

  soildata <- resprop[, varnames]
  resrose <- rosettaPTF::run_rosetta(soildata[,varnames])
  resrose$mukey <- resprop$mukey

  rdf <- data.frame(mukey = as.numeric(terra::cats(res)[[1]][[1]]))
  rdf2 <- merge(rdf, resprop, by = "mukey", all.x = TRUE, sort = FALSE, incomparables = NA)
  rdf3 <- merge(rdf2, resrose, by = "mukey", all.x = TRUE, sort = FALSE, incomparables = NA)
  rdf3 <- rdf3[match(rdf3[["mukey"]], umukeys, incomparables = NA),][1:nrow(resprop),]
  terra::set.cats(res, 1, data.frame(ID = 1:nrow(rdf3), rdf3))

  # @params x a SpatRaster with `levels()` set such that `cats(x)[[1]]` defines the mapping between raster values and one or more new attributes
  # @params columns character vector of column names to map from the categorical levels to raster values
  .cats_to_vars <- function(x, lut = terra::cats(x)[[1]], columns) {

    # lut could in theory be any data.frame (no row limit)

    # read the values (ID values == mukey)
    vls <- terra::values(x)

    # map values from RAT to new numeric values in SpatRaster layer
    terra::rast(lapply(columns, function(colnm) {
      terra::values(x) <- lut[match(vls, lut[[2]], incomparables = NA),
                              match(colnm, colnames(lut), incomparables = NA)]
      names(x) <- colnm
      x
    }))
  }

  resstack <- .cats_to_vars(res, columns = varnames)
  smallstack <- terra::crop(resstack, terra::ext(resstack) / 10)

  # smallstack <-  resstack
  # convert to data.frame, works if it fits in memory
  smallstackdf <- as.data.frame(terra::values(smallstack))
  system.time(test1 <- rosettaPTF::run_rosetta(smallstackdf))
  expect_true(inherits(test1, 'data.frame'))

  # run calculations in blocks using a temporary file to store output, return a SpatRaster
  system.time(test2 <- rosettaPTF::run_rosetta(smallstack))
  expect_true(inherits(test2, 'SpatRaster') &&
                all(table(test1$log10_alpha_mean, useNA = "ifany") ==
                      table(as.numeric(terra::values(test2$log10_alpha_mean)), useNA = "ifany")))

  # set a specific block size (smaller calls to run_rosetta)
  system.time(test3 <- rosettaPTF::run_rosetta(smallstack, nrows = 2))
  expect_true(inherits(test3, 'SpatRaster') &&
                all(table(test1$log10_alpha_mean) ==
                      table(as.numeric(terra::values(test3$log10_alpha_mean)))))

  system.time(test4 <- rosettaPTF::run_rosetta(smallstack, cores = 1))
  system.time(test5 <- rosettaPTF::run_rosetta(smallstack, cores = 2))

  expect_true(inherits(test4, 'SpatRaster') &&
                all(table(test1$log10_alpha_mean) ==
                      table(as.numeric(terra::values(test4$log10_alpha_mean)))))

  expect_true(inherits(test5, 'SpatRaster') &&
                all(table(test1$log10_alpha_mean) ==
                      table(as.numeric(terra::values(test5$log10_alpha_mean)))))
  if (FALSE) {
    system.time(test6 <- rosettaPTF::run_rosetta(smallstack, nrows = 100, cores = 1))
    system.time(test7 <- rosettaPTF::run_rosetta(smallstack, nrows = 100, cores = 2))

    # it fits in memory
    system.time(test8 <- rosettaPTF::run_rosetta(smallstack, cores = 1))
    system.time(test9 <- rosettaPTF::run_rosetta(smallstack, cores = 2))
    system.time(test10 <- rosettaPTF::run_rosetta(smallstack, cores = 8))
  }

})
