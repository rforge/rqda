\name{smartcn}
\alias{smartcn}
\encoding{UTF-8}
\title{
A R interface to the Chinese word segmentation system of lucene-smartcn
}
\description{
  A Chinese word segmentation based on the Chinese analyser lucene-smartcn-3.4.0
}
\usage{
smartcn(text, useStopWord = TRUE)
}
\arguments{
  \item{text}{
    A string vector
  }
    \item{useStopWord}{
    Whether use the default stop words
  }
}
\details{
  It is a wrapper function to a Java Chinese analyser lucene-smartcn-3.4.0.jar. It supports CHS only. CHT should be converted to CHS first.
}
\value{
  A string vector similar to text, with space between Chinese words.
}
\author{
  Ronggui HUANG
}
\examples{
## The example will cause error in latex, so I put it in a demo.
\dontrun{
demo(smartcn,ask=FALSE)
}
}