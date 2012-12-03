getXMP <- function(file, JabrefBibtex=TRUE){
    r <- rJava:::.jnew("RQDAPDF/PDFFile")
    ## r$setPDFDocument("c://SunHuang2012.pdf")
    r$setPDFDocument(file)
    meta <- r$document$getMetadata()
    info <- r$document$getInformation()
    baseDataObject <- info$getBaseDataObject()
    ## author <- info$getAuthor()
    ## title <- info$getTitle()
    jarray <- .jevalArray(baseDataObject$entrySet()$toArray())
    r$document$getBaseDataObject()$getFile()$close()## close the file
    ans <- list()
    for (item in jarray){
        item <- item$toString()
        Encoding(item) <- "UTF-8"
        if (JabrefBibtex) {
           if (grepl("^bibtex", item)) ans <- c(ans, item)
        } else ans <- c(ans, item)
    }
    ans
}
