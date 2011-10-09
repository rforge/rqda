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
    Length-1 string vector.
  }
}
\details{
  It is a wrapper function to a Java Chinese analyser lucene-smartcn-3.4.0.jar.
}
\value{
  A vector similar to text, with space between Chinese words.
}
\author{
  Ronggui HUANG
}
\examples{
smartcn("这是一个中文分词软件")
}