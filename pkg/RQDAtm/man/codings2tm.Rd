\name{codings2tm}
\alias{codings2tm}
\title{RQDA codings to Corpus}
\description{
  Constructs a text document collection (corpus) from RQDA codings.
}
\usage{
codings2tm(Code, language = "eng", byFile = FALSE)
}
\arguments{
  \item{Code}{character vector of length 1, name of a code in RQDA.}
  \item{language}{argument passed to \code{\link[tm]{Corpus}}}
  \item{byFile}{TRUE or FALSE}
}
\details{
  To retrieve the codings of \code{Code}, and turn the codings of 'Code' into a corpus.
}
\value{
  An S4 object of class \code{Corpus}.
}
\author{J-P Mueller and revised and documented by HUANG Ronggui}
\seealso{\code{\link[tm]{Corpus}}}
