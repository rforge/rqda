getXMP <- function(file, JabrefBibtex=TRUE){
    r <- rJava:::.jnew("RQDAPDF/PDFFile")
    r$setPDFDocument(file)
    ## meta <- r$document$getMetadata()
    info <- r$document$getInformation()
    baseDataObject <- info$getBaseDataObject()
    ## author <- info$getAuthor()
    ## title <- info$getTitle()
    jarray <- rJava:::.jevalArray(baseDataObject$entrySet()$toArray())
    r$document$getBaseDataObject()$getFile()$close()## close the file
    keys <- sapply(jarray,function(x) x$getKey()$toString())
    values <- sapply(jarray,function(x) x$getValue()$toString())
    Encoding(values) <- "UTF-8"
    names(values) <- keys
    if (JabrefBibtex) {
        values <- values[grepl("^bibtex", keys)]
    }
    values
}
