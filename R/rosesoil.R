#' Run rosesoil() from rosetta-soil >= 0.3.0
#'
#' @param soildata A list of numeric vectors or a data.frame (3-6 columns: sand, silt, clay, optionally bulk density, th33, and th1500)
#' @param rosetta_version integer, 1-3. Default: 3
#' @param estimate_type _character_. One of `"arith"` (default), `"log"`, or `"geo"`. Only used if `rosetta-soil` >= 0.3.1. `"log"` returns parameters on a logarithmic (log10) scale for `alpha`, `npar`, `ksat`, and `k0`. `"geo"` returns the geometric mean of bootstrap estimates (exponent of the mean of log-transformed values). This is often preferred for parameters that vary by orders of magnitude, such as `alpha` and `ksat`.
#' @param vars optional column name mapping (same as run_rosetta)
#' @return a data.frame with all RosettaResult fields
#' @export
rosesoil <- function(soildata, rosetta_version = 3, estimate_type = "arith", vars = NULL) {
  if (rosetta_pkg_version() < package_version("0.3.0")) {
    stop("rosesoil() requires rosetta-soil >= 0.3.0. Please run install_rosetta(upgrade = TRUE).")
  }

  if (inherits(soildata, "data.frame")) {
    if (!is.null(vars)) {
      if (!all(vars %in% colnames(soildata))) {
        stop("all custom parameter names in `vars` must be present in `soildata`",
             call. = FALSE)
      } else {
        soildata <- soildata[, vars[seq_along(colnames(soildata))]]
      }
    }

    nid <- nrow(soildata)
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
    soildata_list <- unlist(apply(soildatatemplate, 1,
                               function(x)
                                 list(as.numeric(
                                   stats::na.omit(as.numeric(x))
                                 ))),
                         recursive = FALSE)
  } else {
    soildata_list <- soildata
  }

  res_obj <- rosetta_module$rosesoil(as.integer(rosetta_version),
                                    soildata_list,
                                    estimate_type = estimate_type)

  res_dicts <- res_obj$asdicts()

  # handle NULL values in dicts (convert to NA)
  res_df <- do.call(rbind, lapply(res_dicts, function(d) {
    d[sapply(d, is.null)] <- NA_real_
    as.data.frame(d)
  }))

  return(res_df)
}
