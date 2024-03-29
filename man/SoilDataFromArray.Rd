% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rosetta_utils.R
\name{SoilDataFromArray}
\alias{SoilDataFromArray}
\alias{py_to_r.rosetta.rosetta.SoilData}
\title{Convert list of numeric vectors to \emph{SoilData} Python object}
\usage{
SoilDataFromArray(x)

\method{py_to_r}{rosetta.rosetta.SoilData}(x)
}
\arguments{
\item{x}{a list of numeric vectors}
}
\value{
an object reference to a Rosetta \emph{SoilData} Python object constructed from \code{x}
}
\description{
\code{SoilDataFromArray}: convert a list of numeric vectors containing soil properties to a \code{rosetta.rosetta.SoilData} class

\verb{py_to_r(<rosetta.rosetta.SoilData>)}: Wrapper S3 method for SoilData objects to prevent automatic conversion of SoilData (subclass of \code{"python.builtin.list"}) to an R \code{"list"}
}
