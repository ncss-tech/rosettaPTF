% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Class-Rosetta.R
\name{ann_predict}
\alias{ann_predict}
\alias{ann_predict.default}
\alias{ann_predict.Rosetta}
\title{Extended \emph{Rosetta} Predictions, Parameter Distributions and Summary Statistics after Zhang & Schaap (2017)}
\usage{
ann_predict(object, soildata, sum_data = TRUE)

\method{ann_predict}{default}(object, soildata, sum_data = TRUE)

\method{ann_predict}{Rosetta}(object, soildata, sum_data = TRUE)
}
\arguments{
\item{object}{\emph{Rosetta} object containing class instance (e.g. from \code{Rosetta()})}

\item{soildata}{A list containing vectors; with number of parameters matching the model type of \code{object}}

\item{sum_data}{Default: \code{TRUE}}
}
\description{
Extended \emph{Rosetta} Predictions, Parameter Distributions and Summary Statistics after Zhang & Schaap (2017)
}
\examples{
# ann_predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
}
