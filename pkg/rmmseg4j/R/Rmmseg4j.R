## Chinese Word Segmentation

.onLoad <- function(libname, pkgname) {
       .jpackage(pkgname, lib.loc=libname)
     }
     
mmsegDicPath <- function(path = file.path(system.file(package = "rmmseg4j"), "userDic")) {
    .jcall("java/lang/System","S","setProperty","mmseg.dic.path",path)
}

mmseg4j <- function (text, method = c("complex", "maxword"), userDic = NULL)
{
    ## the plugins are from http://code.google.com/p/mmseg4j/
    ## this one seems most meaningful
    ## .jinit(system.file("java","Rmmseg4j.jar",package="rmmseg4j"), force.init = TRUE)
    if (is.null(userDic)) mmsegDicPath() else mmsegDicPath(userDic)
    method = match.arg(method)
    if (class(text) != "character") stop ("text should be character vector")
    N <- length(text)
    Rval <- vector(mode = "character", length = N)
    if (method == "complex") {
        mmseg <- .jnew("Rmmseg4j/RmmsegComplex")
        for (i in seq_len(N)) {
            outRef <- .jcall(mmseg, "S" , "textMethod", text[i], evalString = FALSE)
            Rval[i] <- .jstrVal(outRef)
        }
    }
    if (method=="maxword") {
        mmseg <- .jnew("Rmmseg4j/RmmsegMaxWord")
        for (i in seq_len(N)) {
            outRef <- .jcall(mmseg, "S" , "textMethod", text[i], evalString = FALSE)
            Rval[i] <- .jstrVal(outRef)
        }
    }
    Rval
}
