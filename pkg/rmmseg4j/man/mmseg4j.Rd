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
mmseg4j(text)
}
\arguments{
  \item{text}{
    Length-1 string vector.
  }
}
\details{
  It is a wrapper function to a Java Chinese analyser mmseg4j-1.8.4 \url{http://code.google.com/p/mmseg4j/}, which works for
  simplified Chinese only.
}
\value{
  A vector similar to text, with space between Chinese words.
}
\author{
  Ronggui HUANG
}
\examples{
\dontrun{
mmseg4j("这是一个中文分词软件")
}}