\name{clear}
\alias{clear}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ ~~function to do ... ~~ }
\description{
  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
clear(ask = FALSE, type = c("file", "code", "coding"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{ask}{ ~~Describe \code{ask} here~~ }
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
function(ask=FALSE,type=c("file","code","coding")){
## delete all the "deleted" files/codes/codings (those with status==0)
if (!isIdCurrent(.rqda$qdacon)) print("No project is open!") else {
type <- match.arg(type)
del <- list.deleted(type)
 if (!is.data.frame(del)) print("Nothing to clear.") else {
 if (ask) del <- select.list(del[1,],multiple=TRUE) else del <- del[,1]
if (type=="file"){
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from source where status=0 AND name in (\%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
  } else if (type=="code"){
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from freecode where status=0 AND name in (\%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
  } else if (type=="coding") {
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from coding where status=0 AND seltext in (\%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
  }}
  }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ utilities }

