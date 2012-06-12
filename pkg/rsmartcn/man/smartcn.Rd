\name{smartcn}
\alias{smartcn}
\encoding{UTF-8}
\title{
Chinese Word Segmentation
}
\description{
  Chinese word segmentation based on smartcn
}
\usage{
smartcn(text)
}
\arguments{
  \item{text}{
    A string vector
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