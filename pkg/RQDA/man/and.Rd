\name{and}
\alias{and}
\alias{andSmart}
\title{
  Boolean operation on codings.
}
\description{
  Return codings belong to two codes.
}
\usage{
and(CT1, CT2, showCoding = FALSE, method = c("overlap", "exact",
"inclusion"))

andSmart(CT1, CT2, showCoding = FALSE)
}
\arguments{
  \item{CT1}{
    Coding of code one.
  }
  \item{CT2}{
    Coding of code two.
  }
  \item{showCoding}{
    Logic, return resulting coding if TRUE.
  }
  \item{method}{
    a character vector, used to define the operation of and.
  }
}
\details{
  When the relation of two coding is element of method argument, then
  the overlapping coding is the result of the and operator.

  columns of "index1", "index2","fid","filename" from CT1 and CT2 are
  used by this function.

  The \code{andSmart} is faster. In addition, it will join the adjacent
  codings into one coding.
}
\value{
  a data frame if there is overlapping coding. Otherwise, it is NULL.
}
\author{
  Ronggui HUANG
}
\seealso{
  \code{\link{relation}}, \code{\link{GetCodingTable}}
}
\examples{
\dontrun{
a <- getCodingTable()
c1 <- subset(a,cid==6)
c2 <- subset(a,cid==24)
and(c1,c2,T)
## or use andSmart which is much faster (by a factor about 300)
ans <- andSmart(c1, c2, T)
summary(ans) ## put it into a widget for inspection
}}
