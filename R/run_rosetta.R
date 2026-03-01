#' Run `rosetta()` method from Python module
#'
#' @param soildata A list of numeric vectors each containing 3 to 6 values: `"sand"`, `"silt"`, `"clay"`, `"bulkdensity"`, `"th33"`, `"th1500"`, a _data.frame_ or _matrix_ with 3 to 6 columns OR a `Raster*`/`SpatRaster` object with 3 to 6 layers. Sand, silt, and clay must sum to a total of 100%.
#' @param vars _character_. Optional: names and order of custom column names if `soildata` is a _data.frame_, _RasterStack_, _RasterBrick_ or _SpatRaster_. Default `NULL` assumes input column order follows `sand`, `silt`, `clay`, `bulkdensity`, `th33`, `th1500` and does not check names.
#' @param rosetta_version Default: 3
#' @param estimate_type _character_. One of `"log"` (default), `"arith"`, or `"geo"`. Only used if `rosetta-soil` >= 0.3.1. Default `"log"` preserves logarithmic (log10) scale for `alpha`, `npar`, and `Ksat`. `"geo"` returns the geometric mean of bootstrap estimates (exponent of the mean of log-transformed values). This is often preferred for parameters that vary by orders of magnitude, such as `alpha` and `Ksat`.
#' @param ... additional arguments not used
#'
#' @return A _data.frame_ containing `mean` and `stdev` for the following columns (parameters for van Genuchten-Mualem equation)
#' -	`"theta_r"`, residual water content
#' -	`"theta_s"`, saturated water content
#' -	`"alpha"`, 'alpha' shape parameter (1/cm). Logarithmic (log10) scale if `estimate_type="log"` (default); Geometric mean if `estimate_type="geo"`.
#' -	`"npar"`, 'n' shape parameter. Logarithmic (log10) scale if `estimate_type="log"` (default); Geometric mean if `estimate_type="geo"`.
#' -	`"Ksat"`, saturated hydraulic conductivity (cm/day). Logarithmic (log10) scale if `estimate_type="log"` (default); Geometric mean if `estimate_type="geo"`.
#' -  `"K0"`, unsaturated hydraulic conductivity (cm/day). Only if `rosetta-soil` >= 0.3.1. Logarithmic (log10) scale if `estimate_type="log"` (default); Geometric mean if `estimate_type="geo"`.
#' -  `"lpar"`, unsaturated hydraulic conductivity exponent. Only if `rosetta-soil` >= 0.3.1.
#'
#' If the sum of sand, silt, and clay is not 100%, the parameter value estimates will be `NaN`.
#'
#' @details
#' ## Performance Note
#'
#' Use `cores > 1` with `SpatRaster` or `Raster*` inputs to parallelize processing of cells across multiple cores.
#'
#' @aliases run_rosetta
#' @rdname run_rosetta
#' @export
run_rosetta.default <- function(soildata,
                                vars = NULL,
                                rosetta_version = 3,
                                estimate_type = "log", ...) {

  if (is.numeric(soildata)) {
    soildata <- as.data.frame(t(soildata))
    return(run_rosetta.data.frame(soildata = soildata, vars = vars, rosetta_version = rosetta_version, estimate_type = estimate_type))
  }

  # identify records with enough data
  good.idx <- which(sapply(soildata, length) >= 3)

  if (rosetta_pkg_version() >= package_version("0.3.1")) {
    res <- rosetta_module$rosetta(as.integer(rosetta_version),
                                 soildata[good.idx],
                                 estimate_type = estimate_type)
  } else {
    res <- rosetta_module$rosetta(as.integer(rosetta_version), SoilDataFromArray(soildata[good.idx]))
  }

  if (length(res) == 3) {
    names(res) <- c("mean","stdev","model_codes")

    nc <- ncol(res[[1]])
    if (nc == 7) {
       if (estimate_type == "log") {
         param_names <- c("theta_r", "theta_s", "log10_alpha", "log10_npar", "log10_Ksat", "log10_K0", "lpar")
       } else {
         param_names <- c("theta_r", "theta_s", "alpha", "npar", "ksat", "k0", "lpar")
       }
    } else {
      param_names <- c("theta_r", "theta_s", "log10_alpha", "log10_npar", "log10_Ksat")
    }

    res[[1]] <- as.data.frame(res[[1]])
    colnames(res[[1]]) <- paste0(param_names, "_mean")
    res[[2]] <- as.data.frame(res[[2]])
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
                        estimate_type = "log",
                        cores = 1,
                        core_thresh = NULL,
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
                                   estimate_type = "log",
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

  # Get number of non-NA columns per row
  n_cols <- rowSums(!is.na(soildatatemplate))
  m <- as.matrix(soildatatemplate)
  soildatain <- lapply(seq_len(nid), function(i) {
    m[i, 1:n_cols[i]]
  })

  run_rosetta.default(soildatain, vars = vars, rosetta_version = rosetta_version, estimate_type = estimate_type)
}

#' @export
#' @rdname run_rosetta
run_rosetta.matrix <- function(soildata,
                               vars = NULL,
                               rosetta_version = 3,
                               estimate_type = "log",
                               ...) {
  run_rosetta(as.data.frame(soildata), vars = vars, rosetta_version = rosetta_version, estimate_type = estimate_type)
}

#' @export
#' @rdname run_rosetta
#' @importFrom terra rast
run_rosetta.RasterStack <- function(soildata,
                                    vars = NULL,
                                    rosetta_version = 3,
                                    estimate_type = "log",
                                    cores = 1,
                                    core_thresh = 20000L,
                                    file = paste0(tempfile(), ".tif"),
                                    nrows = nrow(soildata) / (terra::ncell(soildata) / core_thresh),
                                    overwrite = TRUE) {
  run_rosetta(
    terra::rast(soildata),
    vars = vars,
    rosetta_version = rosetta_version,
    estimate_type = estimate_type,
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
                                    estimate_type = "log",
                                    cores = 1,
                                    core_thresh = 20000L,
                                    file = paste0(tempfile(), ".tif"),
                                    nrows = nrow(soildata) / (terra::ncell(soildata) / core_thresh),
                                    overwrite = TRUE) {
  run_rosetta(terra::rast(soildata),
              vars = vars,
              rosetta_version = rosetta_version,
              estimate_type = estimate_type,
              cores = cores,
              file = file,
              nrows = nrows,
              overwrite = overwrite
  )
}
#' @param cores number of cores; used only for processing _SpatRaster_ or _Raster*_ input
#' @param core_thresh Magic number for determining processing chunk size. Default `20000L`. Used to calculate default `nrows`
#' @param file path to write incremental raster processing output for large inputs that do not fit in memory; passed to `terra::writeStart()` and used only for processing _SpatRaster_ or _Raster*_ input; defaults to a temporary file created by `tempfile()` if needed
#' @param nrows number of rows to use per block chunk; passed to `terra::readValues()` and `terra::writeValues()`; used only for processing _SpatRaster_ or _Raster*_ inputs. Defaults to the total number of rows divided by the number of cells divided by `core_thresh`.
#' @param overwrite logical; overwrite `file`? passed to `terra::writeStart()`; defaults to `TRUE` if needed
#' @export
#' @rdname run_rosetta
#' @importFrom terra rast readStart writeStart readValues writeValues writeStop readStop `nlyr<-`
#' @importFrom parallel makeCluster stopCluster parRapply
run_rosetta.SpatRaster <- function(soildata,
                                   vars = NULL,
                                   rosetta_version = 3,
                                   estimate_type = "log",
                                   cores = 1,
                                   core_thresh = 20000L,
                                   file = paste0(tempfile(), ".tif"),
                                   nrows = nrow(soildata) / (terra::ncell(soildata) / core_thresh),
                                   overwrite = TRUE) {

  if (any(!terra::inMemory(soildata))) {
    terra::readStart(soildata)
    on.exit({
      try({
        terra::readStop(soildata)
      }, silent = TRUE)
    }, add = TRUE)
  }

  # create template brick
  out <- terra::rast(soildata)

  # determine output columns by running a small sample
  sample_res <- run_rosetta.default(list(c(33, 33, 34)), rosetta_version = rosetta_version, estimate_type = estimate_type)
  cnm <- colnames(sample_res)

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

  if (cores > 1 && out_info$nrows*ncol(soildata) > core_thresh) {
    cls <- parallel::makeCluster(cores)
    on.exit(parallel::stopCluster(cls))

    for (i in seq_along(start_row)) {
      if (n_row[i] > 0) {
        blockdata <- terra::readValues(soildata, row = start_row[i], nrows = n_row[i], dataframe = TRUE)

        # parallel within-block processing
        n <- max(cores, ceiling(nrow(blockdata) / core_thresh))
        X <- split(blockdata, rep(seq_len(n), length.out = nrow(blockdata)))
        r <- do.call('rbind', parallel::clusterApply(cls, X, function(x) rosettaPTF::run_rosetta(x,
                                                                                                 vars = vars,
                                                                                                 rosetta_version = rosetta_version,
                                                                                                 estimate_type = estimate_type)))

        terra::writeValues(out, as.matrix(r), start_row[i], nrows = n_row[i])
      }
    }
  } else {
    for (i in seq_along(start_row)) {
      if (n_row[i] > 0) {
        foo <- rosettaPTF::run_rosetta(terra::readValues(soildata, row = start_row[i], nrows = n_row[i], dataframe = TRUE),
                                       vars = vars,
                                       rosetta_version = rosetta_version,
                                       estimate_type = estimate_type)
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
