\name{getCodingsByOne}
\alias{getCodingsByOne}
\title{
Return codings of one code.
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
getCodingsByOne(cid)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cid}{
%%     ~~Describe \code{cid} here~~
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
function (cid) 
{
    if (length(cid) != 1) 
        stop("cid should be length-1 integer vector.")
    ct <- RQDAQuery(sprintf("select coding.rowid as rowid, coding.cid, coding.fid, freecode.name as codename, source.name as filename, coding.selfirst as index1, coding.selend as index2, coding.seltext as coding, coding.selend - coding.selfirst as CodingLength from coding left join freecode on (coding.cid=freecode.id) left join source on (coding.fid=source.id) where coding.status==1 and source.status=1 and freecode.status=1 and coding.cid=\%s", 
        cid))
    if (nrow(ct) != 0) {
        Encoding(ct$codename) <- Encoding(ct$filename) <- Encoding(ct$coding) <- "UTF-8"
    }
    class(ct) <- c("codingsByOne", "data.frame")
    ct
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
