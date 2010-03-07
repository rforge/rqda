\name{codedByTwo}
\alias{codedByTwo}
\title{
Show the relationship between *codedBy using a matrix.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
codedByTwo(FUN, codeList = NULL, print = TRUE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{FUN}{
%%     ~~Describe \code{FUN} here~~
}
  \item{codeList}{
%%     ~~Describe \code{codeList} here~~
}
  \item{print}{
%%     ~~Describe \code{print} here~~
}
  \item{\dots}{
%%     ~~Describe \code{\dots} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (FUN, codeList = NULL, print = TRUE, ...) 
{
    FUN <- match.fun(FUN)
    Cid_Name <- RQDAQuery("select id, name from freecode where status==1")
    if (is.null(codeList)) {
        codeList <- gselect.list(Cid_Name$name, multiple = TRUE)
    }
    if (length(codeList) < 2) {
        stop("The codeList should be a vector of length 2 or abvoe.")
    }
    else {
        cidList <- Cid_Name$id[match(codeList, Cid_Name$name)]
        ans <- matrix(nrow = length(codeList), ncol = length(codeList), 
            dimnames = list(sprintf("\%s(\%s)", codeList, cidList), 
                cidList))
        for (i in 1:length(cidList)) {
            for (j in i:length(cidList)) {
                ans[i, j] <- length(do.call(FUN, list(cidList[c(i, 
                  j)])))
            }
        }
        if (print) {
            print(ans, na.print = "")
        }
        invisible(ans)
    }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
