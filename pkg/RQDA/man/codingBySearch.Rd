\name{codingBySearch}
\alias{codingBySearch}
\title{
Auto-coding by pattern matching
}
\description{
Applies the specified code to a specified file based on given text pattern.
}
\usage{
codingBySearch(pattern, fid, cid, unit = "paragraph",...)
}
\arguments{
  \item{pattern}{
a text string, to be matched to the text in the RQDA project file
}
  \item{fid}{
File id, in the GUI 'File' tab click on file to see its id
}
  \item{cid}{
Code id, in the GUI 'Codes' tab click on code to see its id
}
  \item{unit}{
At the moment the available option
}
\item{\ldots}{
  arguments passed to \link{gregexpr}
}
}
\details{
The function can be used if on is interested in automatically applying a code to 
paragraphs in a file based on certain words specified by 'pattern'.  
}
\value{
Thee function is used for its side effect.
}
\author{
Ronggui Huang
}

\seealso{
\link{getFileIds}
}
\examples{
\dontrun{
codingBySearch("internet",fid=1,cid=2)

codingBySearch("internet",fid=getFileIds(),cid=2)
}
}
