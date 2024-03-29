% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_rosetta.R
\name{run_rosetta.default}
\alias{run_rosetta.default}
\alias{run_rosetta}
\alias{run_rosetta.data.frame}
\alias{run_rosetta.matrix}
\alias{run_rosetta.RasterStack}
\alias{run_rosetta.RasterBrick}
\alias{run_rosetta.SpatRaster}
\title{Run \code{rosetta()} method from Python module}
\usage{
\method{run_rosetta}{default}(soildata, vars = NULL, rosetta_version = 3, ...)

\method{run_rosetta}{data.frame}(soildata, vars = NULL, rosetta_version = 3, ...)

\method{run_rosetta}{matrix}(soildata, vars = NULL, rosetta_version = 3, ...)

\method{run_rosetta}{RasterStack}(
  soildata,
  vars = NULL,
  rosetta_version = 3,
  cores = 1,
  core_thresh = 20000L,
  file = paste0(tempfile(), ".tif"),
  nrows = nrow(soildata)/(terra::ncell(soildata)/core_thresh),
  overwrite = TRUE
)

\method{run_rosetta}{RasterBrick}(
  soildata,
  vars = NULL,
  rosetta_version = 3,
  cores = 1,
  core_thresh = 20000L,
  file = paste0(tempfile(), ".tif"),
  nrows = nrow(soildata)/(terra::ncell(soildata)/core_thresh),
  overwrite = TRUE
)

\method{run_rosetta}{SpatRaster}(
  soildata,
  vars = NULL,
  rosetta_version = 3,
  cores = 1,
  core_thresh = 20000L,
  file = paste0(tempfile(), ".tif"),
  nrows = nrow(soildata)/(terra::ncell(soildata)/core_thresh),
  overwrite = TRUE
)
}
\arguments{
\item{soildata}{A list of numeric vectors each containing 3 to 6 values: \code{"sand"}, \code{"silt"}, \code{"clay"}, \code{"bulkdensity"}, \code{"th33"}, \code{"th1500"}, a \emph{data.frame} or \emph{matrix} with 3 to 6 columns OR a \verb{Raster*}/\code{SpatRaster} object with 3 to 6 layers.}

\item{vars}{\emph{character}. Optional: names and order of custom column names if \code{soildata} is a \emph{data.frame}, \emph{RasterStack}, \emph{RasterBrick} or \emph{SpatRaster}. Default \code{NULL} assumes input column order follows \code{sand}, \code{silt}, \code{clay}, \code{bulkdensity}, \code{th33}, \code{th1500} and does not check names.}

\item{rosetta_version}{Default: 3}

\item{...}{additional arguments not used}

\item{cores}{number of cores; used only for processing \emph{SpatRaster} or \emph{Raster*} input}

\item{core_thresh}{Magic number for determining processing chunk size. Default \code{20000L}. Used to calculate default \code{nrows}}

\item{file}{path to write incremental raster processing output for large inputs that do not fit in memory; passed to \code{terra::writeStart()} and used only for processing \emph{SpatRaster} or \emph{Raster*} input; defaults to a temporary file created by \code{tempfile()} if needed}

\item{nrows}{number of rows to use per block chunk; passed to \code{terra::readValues()} and \code{terra::writeValues()}; used only for processing \emph{SpatRaster} or \emph{Raster*} inputs. Defaults to the total number of rows divided by the number of cells divided by \code{core_thresh}.}

\item{overwrite}{logical; overwrite \code{file}? passed to \code{terra::writeStart()}; defaults to \code{TRUE} if needed}
}
\value{
A \emph{data.frame} containing \code{mean} and \code{stdev} for following five columns (parameters for van Genuchten-Mualem equation)
\itemize{
\item \code{"theta_r"}, residual water content
\item \code{"theta_s"}, saturated water content
\item \code{"log10(alpha)"}, 'alpha' shape parameter, log10(1/cm)
\item \code{"log10(npar)"}, 'n' shape parameter
\item \code{"log10(Ksat)"}, saturated hydraulic conductivity, log10(cm/day)
}
}
\description{
Run \code{rosetta()} method from Python module
}
