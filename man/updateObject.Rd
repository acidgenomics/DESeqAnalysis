% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/updateObject-methods.R
\name{updateObject}
\alias{updateObject}
\alias{updateObject,DESeqAnalysis-method}
\title{Update object}
\usage{
updateObject(object, ..., verbose = FALSE)

\S4method{updateObject}{DESeqAnalysis}(object, ..., verbose = FALSE)
}
\arguments{
\item{object}{Object.}

\item{...}{Additional arguments.}

\item{verbose}{\code{logical(1)}.
Verbose output.}
}
\value{
\code{DESeqAnalysis}.
}
\description{
Update object
}
\note{
Updated 2021-02-10.
}
\section{\code{DESeqAnalysis}}{


In the v0.1.8 update, we improved the class to contain \code{Annotated} virtual
class, which adds support for the \code{metadata()} slot. Objects saved by older
package versions must be updated to account for this change.
}

\examples{
data(deseq)

## DESeqAnalysis ====
updateObject(deseq)
}
