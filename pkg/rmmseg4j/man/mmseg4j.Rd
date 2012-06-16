\name{mmseg4j}
\alias{mmseg4j}
\encoding{UTF-8}
\title{
Chinese Word Segmentation
}
\description{
  Chinese word segmentation based on mmseg4j
}
\usage{
mmseg4j(text, method = c("complex", "maxword"), dicDir = NULL)
}
\arguments{
  \item{text}{
    A string vector
  }
  \item{method}{
    Method of segmentation
  }
    \item{dicDir}{
    Directory of user provided dictionary. If NULL, it sets to userDic in the root besides the default dictionaries.
  }
}
\details{
  It is a wrapper function to a Java Chinese analyser mmseg4j-1.8.4 \url{http://code.google.com/p/mmseg4j/}, which works for
  simplified Chinese only.
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
demo(mmseg4j, ask=FALSE)
}
}