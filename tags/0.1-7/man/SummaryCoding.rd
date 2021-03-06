\name{SummaryCoding}
\alias{SummaryCoding}
\alias{print.SummaryCoding}
\title{Summary of coding}
\description{
Give a summary of coding of current project.
}
\usage{
SummaryCoding(byFile = FALSE, ...)
\method{print}{SummaryCoding}
}
\arguments{
  \item{byFile}{When it is FALSE, return the summary of current project. 
When it is TRUE, return the summary of coding for each coded file.}
%  \item{x}{An object returned by \code{SummaryCoding}.}
  \item{\dots}{Other possible arguments.}
}
%\details{
%  ~~ If necessary, more details than the description above ~~
%}
\value{
  A list:
	\item{NumOfCoding}{Number of coding for each code.}
	\item{AvgLength}{Average number of characters in codings for 
each code.}
	\item{NumOfFile}{Number of files coded for each code}.
	\item{CodingOfFile}{Number of codings for each file.NULL is 
byFile is FALSE.}
}
\author{ HUANG Ronggui}
\seealso{\code{\link{GetFileId}} and \code{\link{GetCodingTable}}}
\examples{
\dontrun{
SummaryCoding()
SummaryCoding(FALSE)
}
}
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
