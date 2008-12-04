\name{RQDA-package}
\alias{RQDA-package}
\alias{RQDA}
\docType{package}
\title{
  R-based Qualitative Data Analysis package
}
\description{
  Qualitative Data Analysis based on R language. Current version only supports plain text.
}
\details{
\tabular{ll}{
Package: \tab RQDA\cr
Type: \tab Package\cr
Version: \tab 0.1.5\cr
Date: \tab 2008-11-22\cr
Depends: \tab DBI, RSQLite, RGtk2, gWidgets, gWidgetsRGtk2\cr
License: \tab New style BSD License\cr
LazyLoad: \tab yes\cr
URL: \tab \url{http://rqda.r-forge.r-project.org/} \cr
}
%% description of the package
%% main functions.
The workhorse function for end-user is the RQDA(), you can use RQDA() to
start the GUI after library(QRDA).
}

\note{
The basic usage:
1. Open or create new project.
2. Import files.
3. Select a file and open it by click button open.
4. Add codes.
5. Select a codes, select text segment in the open file, and press
button mark. Select the same text segment and click button Unmark, you
can undo the action.
6. Do more coding as step 5.
7. Select a code and click button retrieval to see what text
segments have been attached to that code.

About memo buttons in the code tab:
1. C-memo is used to attach memo to a selected code. You can select a code then click C-memo button
to view/add memo.
2. C2Memo is used to attach a memo to a coded segments. In the open file, you can see the coded segments
(highlighted), select one segment, and click C2Memo, you can view/add memo to that coded-segment.
}

\author{
  Huang Ronggui
  
  Maintainer: Huang <ronggui.huang@gmail.com>
}

%%\references{
%% reference here
%%}
%%~~ Optionally other standard keywords, one per line, from file KEYWORDS ~~
%%~~ in the R documentation directory ~~
\keyword{ package }
%%\seealso{
%~~ Optional links to other man pages, e.g. ~~
%~~ \code{\link[<pkg>:<pkg>-package]{<pkg>}} ~~
%%}
\examples{
\dontrun{library(RQDA)
RQDA()
}
}
