\name{SearchFiles}
\alias{SearchFiles}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Search files}
\description{
  Search files according to the pattern.
}
\usage{
SearchFiles(pattern, content = FALSE, Widget = NULL, is.UTF8 = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{pattern}{ The criterion of search, see examples section for examples.}
  \item{content}{ When it is TRUE, the content of files fitting the pattern will be returned as well.}
  \item{Widget}{ The name of a gtable widget. If it is not NULL, the file names fitting the pattern will pushed to that gtable widget using \code{svalue} method. One useful value is .rqda\$fnames\_rqda, so the file names will be pushed to the Files Tab of RQDA. }
  \item{is.UTF8}{ If the coding of pattern is UTF-8. If you are not sure, always use FLASE.}
}
\details{
This function use select statment of sql to search files (from source database table). The pattern is the WHERE clause (without the keyword WHERE). For more information, please refer to the website of SQLite syntax. All data in *.rqda use UTF-8 encoding, so the encoding of pattern matters. It will be converted to UTF-8 if it is not (is.UTF8=FALSE).
}
\value{
A data frame with variables:
  \item{id }{The file id.}
  \item{name }{The file name.}
  \item{file }{The file content. Only return when content is TRUE.}
}
\references{ \url{http://www.sqlite.org/lang_expr.html} }
\author{ HUANG Ronggui }
\seealso{\code{\link[gWidgets]{gtable}},  \code{\link[utils]{localeToCharset}}}
\examples{
\dontrun{
SearchFiles("file like '\%keyword\%'") ## search for files who contain the word of "keyword"
SearchFiles("file like 'keyword\%'") ## search for files whose conent begin with the word of "keyword"
SearchFiles("name like '\%keyword'") ## search for files whose name end with the word of "keyword"
SearchFiles("name like '\%keyword one' and file like '\%keyword tow\%' ") ## combined conidtions
}
}
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
