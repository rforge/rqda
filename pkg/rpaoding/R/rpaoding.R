.onLoad <- function(libname, pkgname) {
       rJava:::.jpackage(pkgname, lib.loc=libname)
       ## must use full access of :::
     }
setDicHome <- function(path){
    Sys.setenv("PAODING_DIC_HOME"=path)
}

paoding <- function (text)
{
    dicDir <- file.path(system.file(package = "rpaoding"), "paodingDic")
    setDicHome(dicDir)
    if (class(text) != "character") stop ("text should be character vector")
    pd <- .jnew("rpaoding.rpaoding")
    N <- length(text)
    Rval <- vector(mode = "character", length = N)
    for (i in seq_len(N)){
        ans <- pd$Seg(text[i])
        Encoding(ans) <- "UTF-8"
        Rval[i] <- ans
    }
    Rval
}
