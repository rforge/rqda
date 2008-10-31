\name{list.deleted}
\alias{list.deleted}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ ~~function to do ... ~~ }
\description{
  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
list.deleted(type = c("file", "code", "coding"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{type}{ ~~Describe \code{type} here~~ }
}
\details{
  ~~ If necessary, more details than the description above ~~
}
\value{
  ~Describe the value returned
  If it is a LIST, use
  \item{comp1 }{Description of 'comp1'}
  \item{comp2 }{Description of 'comp2'}
  ...
}
\references{ ~put references to the literature/web site here ~ }
\author{ ~~who you are~~ }
\note{ ~~further notes~~ 

 ~Make other sections like Warning with \section{Warning }{....} ~
}
\seealso{ ~~objects to See Also as \code{\link{help}}, ~~~ }
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function(type=c("file","code","coding")){
## list the deleted file/code/coding
if (!isIdCurrent(.rqda$qdacon)) print("No project is open!") else {
type <- match.arg(type)
if (type=="file"){
ans <- dbGetQuery(.rqda$qdacon, "select name from source where status=0")
  } else if (type=="code"){
ans <- dbGetQuery(.rqda$qdacon, "select name from freecode where status=0")
  } else if (type=="coding") {
ans <- dbGetQuery(.rqda$qdacon, "select seltext from coding where status=0")
  }
  }
if (nrow(ans)==0) sprintf("No \%s is deleted.",type) else ans
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ utilities }

