\name{pdfAnnotations}
\alias{pdfAnnotations}
\title{
  Extract highlighted or underlined text from a PDF file
}
\description{
  Extract highlighted or underlined text from a PDF file
}
\usage{
pdfAnnotations(file, type=c("Highlight", "Popup"), collapse = TRUE)
}
\arguments{
  \item{file}{charater, path of a PDF file.}
  \item{type}{Type of text exerpts.}
  \item{collapse}{logical, the result is concatenated into a single string when TRUE.}
}
\details{
  This function uses the jPod java library to do the hardwork.

  To extract the highlighted text, the highlighted must be created with
  specific PDF reader. You can refer to Docear project
  \url{http://www.docear.org/support/user-manual/#compatible_pdf_readers}
  for settings of PDF reader.  
}
\value{
  character vector of the extracted text.
}
\author{
Ronggui HUANG
}
