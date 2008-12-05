\name{relation}
\alias{relation}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Relation between two codings}
\description{
  To calculate the relation between two codings, given the coding indexes.
}
\usage{
relation(index1, index2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{index1}{ The first coding index, it is length-2 integer vector
    with index1[1] < index1[2]}
  \item{index2}{ The second coding index, it is length-2 integer vector
    with index2[1] < index2[2].}
}
\details{
The relation between two codings can be any of inclusion, overlap, exact
(special case of inclusion and overlap) and proximity (Neither overlap
nor inclusion).
}
\value{
  A 5-element list:
  \item{Relation}{Length-1 character, standing for the type of
    relation. It may be one of inclusion, overlap, exact or proximity.}
  \item{OverlapIndex}{Length-2 vector, the index of overlapping between
    two coding indexes. It is c(NA,NA) when relation is proximity.}
  \item{UnionIndex}{Length-2 vector, the index of union of the two
    coding indexes. It is c(NA,NA) when relation is proximity.}
  \item{Distance}{Distance of two coding indexes. It is NA when relation is not proximity.}
  \item{WhichMin}{Is is 1 when index1 has the minimum index, 2 when
    index2 has the minimum index. When they have the same minimum
    index,it is 1 when index1 has the max index, it is 2 when index2 has
    the max index. It is NA when relation is Exact.}
}
\author{ HUANG Ronggui}
%\seealso{ ~~objects to See Also as \code{\link{help}}, ~~~ }
\examples{
\dontrun{
relation(c(20,30),c(22,28)) # inclusion
relation(c(10,40),c(20,80)) # overlap
relation(c(10,20),c(30,50)) # proximity with distance of 10
relation(c(10,20),c(10,20)) # exact
relation(c(10,20),c(10,30)) # WhichMin is 2
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
