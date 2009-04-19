\name{RQDATables}
\alias{RQDATables}
\title{Data Tables in rqda file}
\description{
The internal data table structures in rqda file, which is a SQLite data base.
}
\details{
  The source table contains the content of files.
  \tabular{ll}{
    name:\tab name of the file.\cr
    id:\tab id of the file.\cr
    file:\tab content of a file.\cr
    memo:\tab memo of the file.\cr
    owner:\tab creator the the file.\cr
    date:\tab the date of the file-import.\cr
    dataM:\tab not used now.\cr
    status:\tab 1 for standard status and 0 for temporarily deleted file.\cr
  }

  The filecat table contains information on the file categorization.
  \tabular{ll}{
    name:\tab name of the file category.\cr
    fid:\tab file id.\cr
    
  }

}
\author{ HUANG Ronggui }
