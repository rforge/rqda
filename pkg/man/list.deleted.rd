\name{File/code/coding deletion}
\alias{list.deleted}
\alias{pdelete}
\alias{undelete}
\title{ Show, permanently delete or un-delete(reuse) the unused file, code, and coding.}
\description{
  \code{list.deleted} shows the file, code and coding tagged with deletion
  mark.
  \code{pdelete} Permanently delete them.
  \code{undelete} let you reuse the temporary tagged as deleted file and code.
}
\usage{
list.deleted(type = c("file","code","case","codecategory","coding"))
pdelete(type = c("file","code","case","codecategory","coding"),ask = FALSE)
undelete(type=c("file","code"))
}

\arguments{
  \item{type}{ What kind of info would you like to show or clear.$_file_$
  is the name of file (in the Files tab). $_code_$ is the name of codes
  (in the Codes tab). $_case_$ is the
  name of case (in the Case tab). $_codecategory_$ is name of code
  category (in the C-Cat tab). $_coding_$ is the text segment associated
  with specific code.}
  \item{ask} {You can choose which ones to be deleted when is
  TRUE. Otherwise, it will delete all with temporary tagged with
  deletion mark, that is status=0.}
}

\details{
  By GUI, you can delete file and code (together with the related
  coding), which just sets the status from 1 to 0. In this sense,
  deletion from GUI is temporary.After that, you can use
  \code{list.deleted} to show which ones are tagged as deleted.
  By \code{pdelete}, you can permenantly delete those tagged with mark
  of status=0, all of them by setting ask=FALSE, or you can choose which
  ones to be deleted permenantly.By \code{undelete}, you can undo the
  temporary deleted files and codes. It offers a GUI so you can choose
  in the list. For the time being, it is not the true reserve process of
  GUI  deletion, as the deletion-tagged coding will not set to the
  original status.
}

\value{
For \code{list.deleted}, a data frame if there are some item tagged with
status=0.
For \code{pdelete} and \code{undelete}, no value is return. This
function is for is side-effect.
}

\author{Ronggui HUANG}
\keyword{ utilities }

