\name{RQDATables}
\alias{RQDATables}
\title{Data Tables in rqda file}
\description{
The internal data table structures in rqda file, which is a SQLite data base.
}
\details{
  The "attributes" table contains the definition of atrributes.
%   \tabular{ll}{

% }

  The "coding" table contains information on codings.
  \tabular{ll}{
    cid :\tab \cr 
    fid :\tab \cr 
    seltext :\tab \cr 
    selfirst :\tab \cr 
    selend :\tab \cr 
    status :\tab \cr 
    owner :\tab \cr 
    date :\tab \cr 
    memo :\tab \cr 
  }

    The "filecat" table contains information on the file categorization.
  \tabular{ll}{
    name:\tab name of the file category.\cr
    fid:\tab file id.\cr
    catid:\tab if of file category.\cr
    owner:\tab creator of file-category.\cr
    date:\tab \cr
    dateM:\tab \cr
    memo:\tab \cr
    status:\tab \cr
  }

  The "freecode" table contains information on the codes list.
  \tabular{ll}{
    name :\tab \cr 
    memo :\tab \cr 
    owner :\tab \cr 
    date :\tab \cr 
    dateM :\tab \cr 
    id :\tab \cr 
    status :\tab \cr
  }
  
  The "source" table contains the content of files.
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
  
  The "treecode" table contains information on the codes category.
%   \tabular{ll}{
    
%   }
  
}
\author{ HUANG Ronggui }
