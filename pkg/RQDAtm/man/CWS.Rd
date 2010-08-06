\name{CWS}
\alias{CWSmmseg}
\alias{CWSimdict}
\alias{CWSik}
\title{
Chinese Word Segmentation
}
\description{
  Chinese word segmentation
}
\usage{
CWSmmseg(text)

CWSik(text)

CWSimdict(text, stpword=TRUE)
}
\arguments{
  \item{text}{
    Length-1 string vector.
  }
  \item{stpword}{
    When TRUE, stop words are not included in the returned value.
  }
}
\details{
  There are wrapper functions to various Java Chinese analyser.
}
\value{
  A vector similar to text, with space between Chinese words.
}
\author{
  Ronggui HUANG
  
  Benson Ye (bensonye@189.cn) provided a protype of \code{CWSimdict} and
  Java code of the plugin.
}
\note{
  The mmseg4j analyser, \url{http://code.google.com/p/mmseg4j/}
  
  The imdict Chinese analyser, \url{http://code.google.com/p/imdict-chinese-analyzer/}

  The IK-analyser, \url{http://code.google.com/p/ik-analyzer/}
}
%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%}
\examples{
CWSimdict("This is a testing.")
}