extractPDF <- function(file, type=c("Highlight", "Underline", "Both"), collapse = TRUE) {
    type <- match.arg(type)
    if (type == "Both") type <- c("Highlight", "Underline")
    r <- rJava:::.jnew("RQDAPDF/PDFFile")
    if (!grepl("[.]pdf$", file)) stop("a PDF file is expected")
    r$setPDFDocument(file)
    ans <- c()
    ps <- r$getPDFNumberOfPages()
    for (page in (seq_len(ps)-1)){
        r$PDFPageAnnotations(as.integer(page)) ## go to page
        Nanno <- tryCatch(r$pageannotations$size(),error=function(e) 0) ## number of annotations
        if (Nanno>0) {
            for (anno.idx in (seq_len(Nanno)-1)){
                anno <- r$PDFPageAnnotation(as.integer(anno.idx))
                if (anno$getClass()$toString() == "class org.pdfclown.documents.interaction.annotations.TextMarkup") {
                    if (anno$getMarkupType()$toString() %in% type) {
                        text <- anno$getText()
                        if (!is.null(text)) {
                            Encoding(text) <- "UTF-8"
                            text <- gsub("\u0093","f", text)
                            text <- sprintf("Page.%i:%s", page+1, text)
                            ans <- c(ans, text)
                        }
                    }
                }
            }
        }
    }
    r$document$getBaseDataObject()$getFile()$close()## close the file
    if (length(ans)==0) ans <- "" else {
        ans <- gsub("\r\n", "", gsub(" {1,}\r\n", "\n\n", ans))
        if (collapse) ans <- paste(ans, collapse="\n\n")
    }
    attr(ans, "file") <- basename(file)
    ans
}
