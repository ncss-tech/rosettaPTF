#' Run `rosetta()` method from Python module
#'
#' @param soildata A list of numeric vectors containing 3 to 6 elements: `"sand"`, `"silt"`, `"clay"`, `"bulkdensity"`, `"th33"`, `"th1500"`
#' @param rosetta_version Default: 3
#'
#' @return A _data.frame_ containing `mean` and `stdev` for following five columns (parameters for van Genuchten-Mualem equation)
#' -	`theta_r`, residual water content
#' -	`theta_s`, saturated water content
#' -	`log10(alpha)`, 'alpha' shape parameter, log10(1/cm)
#' -	`log10(npar)`, 'n' shape parameter
#' -	`log10(Ksat)`, saturated hydraulic conductivity, log10(cm/day)
#'
#' @export
#'
run_rosetta <- function(soildata, rosetta_version = 3) {
  res <- rosetta_module$rosetta(rosetta_version, SoilDataFromArray(soildata))
  if (length(res) == 3) {
    names(res) <- c("mean","stdev","model_codes")
    param_names <- c("theta_r", "theta_s", "log10_alpha", "log10_npar", "log10_Ksat")
    res[[1]] <- as.data.frame(res[[1]])
    colnames(res[[1]]) <- paste0(param_names, "_mean")
    colnames(res[[2]]) <- paste0(param_names, "_sd")
    return(data.frame(id = 1:nrow(res[[1]]), model_code = res[[3]], cbind(res[[1]], res[[2]])))
  }
  res
}
