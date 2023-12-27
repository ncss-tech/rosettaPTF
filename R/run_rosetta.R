#' Run `rosetta()` method from Python module
#'
#' @param soildata A list of numeric vectors each containing 3 to 6 values: `"sand"`, `"silt"`, `"clay"`, `"bulkdensity"`, `"th33"`, `"th1500"`, a _data.frame_ or _matrix_ with 3 to 6 columns OR a `Raster*`/`SpatRaster` object with 3 to 6 layers.
#'
#' @param vars _character_. Optional: names and order of custom column names if `soildata` is a _data.frame_, _RasterStack_, _RasterBrick_ or _SpatRaster_. Default `NULL` assumes input column order follows `sand`, `silt`, `clay`, `bulkdensity`, `th33`, `th1500` and does not check names.
#' @param rosetta_version Default: 3
#' @param ... additional arguments not used
#' @return A _data.frame_ containing `mean` and `stdev` for following five columns (parameters for van Genuchten-Mualem equation)
#' -	`"theta_r"`, residual water content
#' -	`"theta_s"`, saturated water content
#' -	`"log10(alpha)"`, 'alpha' shape parameter, log10(1/cm)
#' -	`"log10(npar)"`, 'n' shape parameter
#' -	`"log10(Ksat)"`, saturated hydraulic conductivity, log10(cm/day)
#' @aliases run_rosetta
#' @rdname run_rosetta
#' @export
run_rosetta.default <- function(soildata,
                                vars = NULL,
                                rosetta_version = 3, ...) {

  if (is.numeric(soildata)) {
    soildata <- as.data.frame(t(soildata))
    run_rosetta.data.frame(soildata = soildata, vars = vars, rosetta_version = rosetta_version)
  }

  # identify records with enough data
  good.idx <- which(sapply(soildata, length) >= 3)

  # run rosetta
  res <- rosetta_module$rosetta(rosetta_version, SoilDataFromArray(soildata[good.idx]))

  if (length(res) == 3) {
    names(res) <- c("mean","stdev","model_codes")
    param_names <- c("theta_r", "theta_s", "log10_alpha", "log10_npar", "log10_Ksat")
    res[[1]] <- as.data.frame(res[[1]])
    colnames(res[[1]]) <- paste0(param_names, "_mean")
    colnames(res[[2]]) <- paste0(param_names, "_sd")

    res <- data.frame(model_code = res[[3]], cbind(res[[1]], res[[2]]))
    restemplate <- res[0,][1:length(soildata),]
    restemplate[good.idx,] <- res

    rownames(restemplate) <- NULL

    return(cbind(id = 1:nrow(restemplate), restemplate))
  } else {
    stop("rosetta result should contain `mean`, `stdev`, and `model_codes` list elements",
         call. = FALSE)
  }
}

#' @export
run_rosetta <- function(soildata,
                        vars = NULL,
                        rosetta_version = 3,
                        cores = 1,
                        file = NULL,
                        nrows = NULL,
                        overwrite = NULL)
  UseMethod("run_rosetta", soildata)

#' @export
#' @rdname run_rosetta
#' @importFrom stats na.omit
run_rosetta.data.frame <- function(soildata,
                                   vars = NULL,
                                   rosetta_version = 3,
                                   ...) {

  # soildata <- as.data.frame(soildata)
  nid <- nrow(soildata)

  if (ncol(soildata) < 3) {
    stop(
      "if `soildata` is a data.frame it must contain three to six columns: `sand`, `silt`, and `clay` are required; optionally including `bulkdensity` and water retention (`th33` and `th1500`) values. You can specify custom column names and order with the `vars` argument.",
      call. = FALSE
    )
  }

  if (!is.null(vars)) {
    if (!all(vars %in% colnames(soildata))) {
      stop("all custom parameter names in `vars` must be present in `soildata`",
           call. = FALSE)
    } else {
      # re-arrange and subset to match vars order
      soildata <- soildata[, vars[seq_along(colnames(soildata))]]
    }
  }

  soildatatemplate <- data.frame(
    sand = numeric(nid),
    silt = numeric(nid),
    clay = numeric(nid),
    bulkdensity = numeric(nid),
    th33 = numeric(nid),
    th1500 = numeric(nid)
  )
  soildatatemplate[] <- NA_real_
  soildatatemplate[, 1:ncol(soildata)] <- soildata
  soildatain <- unlist(apply(soildatatemplate, 1,
                             function(x)
                               list(as.numeric(
                                 na.omit(as.numeric(x))
                               ))),
                       recursive = FALSE)
  run_rosetta.default(soildatain, vars = vars, rosetta_version = rosetta_version)
}

#' @export
#' @rdname run_rosetta
run_rosetta.matrix <- function(soildata,
                               vars = NULL,
                               rosetta_version = 3,
                               ...) {
  run_rosetta(as.data.frame(soildata), vars = vars, rosetta_version = 3)
}

#' @export
#' @rdname run_rosetta
#' @importFrom terra rast
run_rosetta.RasterStack <- function(soildata,
                                    vars = NULL,
                                    rosetta_version = 3,
                                    cores = 1,
                                    file = paste0(tempfile(),".grd"),
                                    nrows = nrow(soildata),
                                    overwrite = TRUE) {
  ## for in memory only, can just convert to data.frame and use that method
  # res <- run_rosetta(raster::as.data.frame(soildata),
  #                    vars = vars,
  #                    rosetta_version = rosetta_version)
  # resstackout <- soildata
  # for(i in 1:ncol(res)) {
  #   resstackout[[i]] <- res[[i]]
  # }
  # names(resstackout) <- colnames(res)
  # resstackout
  run_rosetta(
    terra::rast(soildata),
    vars = vars,
    rosetta_version = rosetta_version,
    cores = cores,
    file = file,
    nrows = nrows,
    overwrite = overwrite
  )
}

#' @export
#' @rdname run_rosetta
#' @importFrom terra rast
run_rosetta.RasterBrick <- function(soildata,
                                    vars = NULL,
                                    rosetta_version = 3,
                                    cores = 1,
                                    file = paste0(tempfile(),".grd"),
                                    nrows = nrow(soildata),
                                    overwrite = TRUE) {
  run_rosetta(terra::rast(soildata),
              vars = vars,
              rosetta_version = rosetta_version,
              cores = cores,
              file = file,
              nrows = nrows,
              overwrite = overwrite
  )
}
#' @param cores number of cores; used only for processing _SpatRaster_ or _Raster*_ input
#' @param file path to write incremental raster processing output for large inputs that do not fit in memory; passed to `terra::writeStart()` and used only for processing _SpatRaster_ or _Raster*_ input; defaults to a temporary file created by `tempfile()` if needed
#' @param nrows number of rows to use per block; passed to `terra::readValues()` `terra::writeValues()`; used only for processing _SpatRaster_ or _Raster*_ input; defaults to number of rows in dataset if needed
#' @param overwrite logical; overwrite `file`? passed to `terra::writeStart()`; defaults to `TRUE` if needed
#' @export
#' @rdname run_rosetta
#' @importFrom terra rast readStart writeStart readValues writeValues writeStop readStop `nlyr<-`
#' @importFrom parallel makeCluster stopCluster parRapply
run_rosetta.SpatRaster <- function(soildata,
                                   vars = NULL,
                                   rosetta_version = 3,
                                   cores = 1,
                                   file = paste0(tempfile(),".grd"),
                                   nrows = nrow(soildata),
                                   overwrite = TRUE) {

  if (!terra::inMemory(soildata)) {
    terra::readStart(soildata)
    on.exit({
      try({
        terra::readStop(soildata)
      }, silent = TRUE)
    }, add = TRUE)
  }

  # create template brick
  out <- terra::rast(soildata)
  cnm <- c("id", "model_code", "theta_r_mean", "theta_s_mean", "log10_alpha_mean",
           "log10_npar_mean", "log10_Ksat_mean", "theta_r_sd", "theta_s_sd",
           "log10_alpha_sd", "log10_npar_sd", "log10_Ksat_sd")
  terra::nlyr(out) <- length(cnm)
  names(out) <- cnm
  out_info <- terra::writeStart(out, filename = file, overwrite = overwrite)

  on.exit({
    try({
      out <- terra::writeStop(out)
    }, silent = TRUE)
  }, add = TRUE)

  start_row <- seq(1, out_info$nrows, nrows)
  n_row <- diff(c(start_row, out_info$nrows + 1))

  if (cores > 1 && out_info$nrows*ncol(soildata) > 20000) {
    cls <- parallel::makeCluster(cores)
    on.exit(parallel::stopCluster(cls))

    # TODO: can blocks be parallelized?
    for(i in seq_along(start_row)) {
      if (n_row[i] > 0) {
        blockdata <- terra::readValues(soildata, row = start_row[i], nrows = n_row[i], dataframe = TRUE)
        ids <- 1:nrow(blockdata)
        # soilDB makeChunks logic; what is tradeoff between chunk size and number of requests?
        # run_rosetta is a "costly" function and not particularly fast, so in theory parallel would help

        # parallel within-block processing
        X <- split(blockdata, rep(seq(from = 1, to = floor(length(ids) / 20000) + 1), each = 20000)[1:length(ids)])
        r <- do.call('rbind', parallel::clusterApply(cls, X, function(x) rosettaPTF::run_rosetta(x,
                                                                                                 vars = vars,
                                                                                                 rosetta_version = rosetta_version)))

        terra::writeValues(out, as.matrix(r), start_row[i], nrows = n_row[i])
      }
    }
  } else {
    for(i in seq_along(start_row)) {
      if (n_row[i] > 0) {
        foo <- rosettaPTF::run_rosetta(terra::readValues(soildata, row = start_row[i], nrows = n_row[i], dataframe = TRUE),
                                       vars = vars,
                                       rosetta_version = rosetta_version)
        terra::writeValues(out, as.matrix(foo), start_row[i], nrows = n_row[i])
      }
    }
  }

  # replace NaN with NA_real_ (note: not compatible with calling writeStop() on.exit())
  # out <- terra::classify(out, cbind(NaN, NA_real_)) #terra::values(out)[is.nan(terra::values(out))] <- NA_real_

  out
}

# TODO:
# run_rosetta.SpatRasterDataset
