## Chinese Word Segmentation
## This is part of rsmartcn

#.onAttach <- function(...) {
#    .jinit(system.file("plugins","rsmartcn.jar",package="rsmartcn"))
#}

.onLoad <- function(libname, pkgname) {
       rJava:::.jpackage(pkgname, lib.loc=libname)
       ## must use full access of :::
     }

smartcn <- function (text, useStopWord = TRUE)
{
    if (class(text) != "character") stop ("text should be character vector")
    smartcn <- .jnew("rsmartcn.rsmartcn")
    stopWord <- .jnew("java.lang.Boolean", ifelse(useStopWord, "true", "false"))
    N <- length(text)
    Rval <- vector(mode = "character", length = N)
    for (i in seq_len(N)){
        ans <- smartcn$Seg(text[i], stopWord$booleanValue())
        Encoding(ans) <- "UTF-8"
        Rval[i] <- ans
    }
    Rval
}
