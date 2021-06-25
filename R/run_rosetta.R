#' Run `rosetta()` method from Python module
#'
#' @param soildata A list of numeric vectors each containing 3 to 6 values: `"sand"`, `"silt"`, `"clay"`, `"bulkdensity"`, `"th33"`, `"th1500"` or a _data.frame_ with 3 to 6 columns.
#' @param vars _character_. Optional: names and order of custom column names if `soildata` is a _data.frame_. Default `NULL` assumes input column order follows `sand`, `silt`, `clay`, `bulkdensity`, `th33`, `th1500` and does not check names.
#' @param rosetta_version Default: 3
#'
#' @return A _data.frame_ containing `mean` and `stdev` for following five columns (parameters for van Genuchten-Mualem equation)
#' -	`theta_r`, residual water content
#' -	`theta_s`, saturated water content
#' -	`log10(alpha)`, 'alpha' shape parameter, log10(1/cm)
#' -	`log10(npar)`, 'n' shape parameter
#' -	`log10(Ksat)`, saturated hydraulic conductivity, log10(cm/day)
#' @aliases run_rosetta
#' @rdname run_rosetta
#' @export
run_rosetta.default <- function(soildata,
                                vars = NULL,
                                rosetta_version = 3) {

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
                        rosetta_version = 3)
  UseMethod("run_rosetta", soildata)

#' @export
#' @rdname run_rosetta
#' @importFrom stats na.omit
run_rosetta.data.frame <- function(soildata,
                                   vars = NULL,
                                   rosetta_version = 3) {

  if (inherits(soildata, 'data.frame')) {
    soildata <- as.data.frame(soildata)
    nid <- nrow(soildata)

    if (ncol(soildata) < 3) {
      stop("if `soildata` is a data.frame it must contain three to six columns: `sand`, `silt`, and `clay` are required; optionally including `bulkdensity` and water retention (`th33` and `th1500`) values. You can specify custom column names and order with the `vars` argument.", call. = FALSE)
    }

    if (!is.null(vars)) {
      if (!all(vars %in% colnames(soildata))) {
        stop("all custom parameter names in `vars` must be present in `soildata`", call. = FALSE)
      } else {
        # re-arrange and subset to match vars order
        soildata <- soildata[,vars[seq_along(colnames(soildata))]]
      }
    }

    soildatatemplate <- data.frame(sand = numeric(nid),
                                   silt = numeric(nid),
                                   clay = numeric(nid),
                                   bulkdensity = numeric(nid),
                                   th33 = numeric(nid),
                                   th1500 = numeric(nid))
    soildatatemplate[] <- NA_real_
    soildatatemplate[,1:ncol(soildata)] <- soildata
    soildatain <- unlist(apply(soildatatemplate, 1,
                               function(x) list(as.numeric(na.omit(as.numeric(x))))),
                         recursive = FALSE)
  } else {
    soildatain <- soildata
  }
  run_rosetta.default(soildatain, vars=vars, rosetta_version=rosetta_version)
}

#' @export
#' @rdname run_rosetta
#' @importFrom raster as.data.frame
run_rosetta.RasterStack <- function(soildata,
                               vars = NULL,
                               rosetta_version = 3) {
  res <- run_rosetta(raster::as.data.frame(soildata), vars = vars, rosetta_version = rosetta_version)
  resstackout <- soildata
  for(i in 1:ncol(res)) {
    resstackout[[i]] <- res[[i]]
  }
  names(resstackout) <- colnames(res)
  resstackout
}
