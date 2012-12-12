pdfXMP <- function(file, jabrefOnly=TRUE){
    commonjpod <- rJava:::.jnew("common/CommonRJPod")
    commonjpod$open(file)
    doc <- commonjpod$getDoc()
    info <- doc$getInfoDict()
    dic <- info$cosGetObject()
    ks <- dic$keySet()
    ks <- rJava:::.jevalArray(ks$toArray())
    ans <- sapply(ks, function(x) {
        key <- x$toString()
        val <- dic$get(x)$toString()
        Encoding(key) <- Encoding(val) <- "UTF-8"
        key <- gsub("^/", "", key)
        val <- gsub("^(\\()|(\\)$)", "", val)
        sprintf("%s = %s", key, val)
    })
    if (jabrefOnly) {
        ans <- ans[grepl("^bibtex",ans)]
    }
    ans
}
