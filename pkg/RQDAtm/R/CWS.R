## Chinese Word Segmentation
CWSimdict <- function (text,stpword=TRUE)
{
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    if (isTRUE(stpword)) stpword <- "true" else stpword="false"
    .jinit(system.file("plugins","CWSimdict.jar",package="RQDAtm"))
    ## the plugins are from http://code.google.com/p/imdict-chinese-analyzer/ and lucene 2.93
    imdict <- .jnew("org.apache.lucene.analysis.cn.CWSimdict")
    outRef <- .jcall(imdict, "S" , "txtMethod", text, stpword, evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}

CWSmmseg <- function (text)
{
## the plugins are from http://code.google.com/p/mmseg4j/
## this one seems most meaningful
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","CWSmmseg4j.jar",package="RQDAtm"))
    mmseg <- .jnew("com/chenlb/mmseg4j/example/CWSmmseg")
    outRef <- .jcall(mmseg, "S" , "txtMethod",text,evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}

CWSik <- function (text)
{
## the plugins are from http://code.google.com/p/ik-analyzer/
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","IKCWS.jar",package="RQDAtm"))
    ikcws <- .jnew("org/wltea/analyzer/example/IKCWS")
    outRef <- .jcall(ikcws, "S" , "segWords",text,evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}


