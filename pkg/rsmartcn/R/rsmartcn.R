## Chinese Word Segmentation
## This is part of rsmartcn

#.onAttach <- function(...) {
#    .jinit(system.file("plugins","rsmartcn.jar",package="rsmartcn"))
#}

.onLoad <- function(libname, pkgname) {
       rJava:::.jpackage(pkgname, lib.loc=libname)
       ## must use full access of :::
     }

smartcn <- function (text)
{
    if (class(text) != "character") stop ("text should be character vector")
    smartcn <- .jnew("rsmartcn.rsmartcn")
    N <- length(text)
    Rval <- vector(mode = "character", length = N)
    for (i in seq_len(N)){
        outRef <- .jcall(smartcn, "S" , "textMethod", text[i], evalString = FALSE)
        Rval[i] <- .jstrVal(outRef)
    }
    Rval
}
