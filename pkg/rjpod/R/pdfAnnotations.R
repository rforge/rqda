pdfAnnotations <- function(file, type=c("Highlight", "Popup"), collapse=TRUE){
    type <- match.arg(type)
    commonjpod <- .jnew("common/CommonRJPod")
    commonjpod$open(file)
    doc <- commonjpod$getDoc()
    anns <- doc$getAnnotations()
    annsArray <- anns$toArray()
    annsArray <- .jevalArray(annsArray)
    types <- sapply(annsArray, function(x) x$getSubtypeLabel())
    idx <- types %in% "Highlight"
    annsArray <- annsArray[idx]
    ans <- sapply(annsArray, function(x) x$getContents())
    Encoding(ans) <- "UTF-8"
    commonjpod$close()
    if (collapse) ans <- paste(ans, collapse="\n\n")
    ans
}
