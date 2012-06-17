## Chinese Word Segmentation

.onLoad <- function(libname, pkgname) {
       rJava:::.jpackage(pkgname, lib.loc=libname)
       ## must use full access of :::
     }

mmseg4j <- function (text, method = c("complex", "maxword", "simple"), dicDir = NULL, reload = FALSE)
{
    ## the plugins are from http://code.google.com/p/mmseg4j/
    ## this segmentation softeware seems most useful
    ## .jinit(system.file("java","Rmmseg4j.jar",package="rmmseg4j"), force.init = TRUE)
    method = match.arg(method)
    if (class(text) != "character") stop ("text should be character vector")
    N <- length(text)
    Rval <- vector(mode = "character", length = N)
    if (method == "complex")  mmseg <- .jnew("Rmmseg4j/RmmsegComplex")
    if (method=="maxword")  mmseg <- .jnew("Rmmseg4j/RmmsegMaxWord")
    if (method=="simple")  mmseg <- .jnew("Rmmseg4j/RmmsegSimple")
    if (!is.null(dicDir)) {
        mmseg$dic <- mmseg$dic$getInstance(dicDir)
    } else {
        mmseg$dic <-  mmseg$dic$getInstance(file.path(system.file(package = "rmmseg4j"), "userDic"))
    }
    if (reload) mmseg$dic$reload()
    for (i in seq_len(N)) {
        Val <- mmseg$segWords(text[i], " ")
        Encoding(Val) <- "UTF-8"
        Rval[i] <- Val
    }
    Rval
}
