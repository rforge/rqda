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
mmseg4j(text, method = c("complex", "maxword", "simple"), dicDir = NULL)
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
\note{
  This functin requires Java Runtime Environment (build 1.6.0_21-b07) or later.
}

\value{
  A string vector similar to text, with space between Chinese words.
}
\author{
  Ronggui HUANG
}
\examples{
## Use the following command to open the example file
## then you can copy and paste the commands into R

## file.show(file.path(path.package("rmmseg4j"),"mmseg4jExample.R"))
}