\name{RQDATables}
\alias{RQDATables}
\title{Data Tables in rqda file}
\description{
The internal data table structures in rqda file, which is a SQLite data base.
}
\details{
  The source table contains the content of files.
  \item{name}{name of the file.}
  \item{id}{id of the file.}
  \item{file}{content of a file.}
  \item{memo}{memo of the file.}
  \item{owner}{creator the the file.}
  \item{date}{the date of the file-import.}
  \item{dataM}{not used now.}
  \item{status}{status of the file, 1 for standard status and 0 for
    temporarily deleted file.}

  The filecat table contains information on the file categorization.
  \item{name}{name of the file category.}
  \item{fid}{file id.}
}
\author{ HUANG Ronggui }
