## Chinese Word Segmentation
CWS <- CWSimdict <- function (text,stpwords=FALSE)
{
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    if (isTRUE(stpwords)) zj <- "true" else zj <- "false"
    .jinit(system.file("plugins","CWSimdict.jar",package="RQDAtm"))
    ## the plugins are from http://code.google.com/p/imdict-chinese-analyzer/
    hjw <- .jnew("org.apache.lucene.analysis.cn.hzfc")
    outRef <- .jcall(hjw, "S" , "txtMethod",text,zj, evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}

CWSmmseg <- function (text)
{
## http://code.google.com/p/mmseg4j/
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","CWSmmseg4j.jar",package="RQDAtm"))
    mmseg <- .jnew("com/chenlb/mmseg4j/example/CWSmmseg")
    outRef <- .jcall(mmseg, "S" , "txtMethod",text,evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}

CWSik <- function (text)
{
## http://code.google.com/p/ik-analyzer/
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","IKCWS.jar",package="RQDAtm"))
    ikcws <- .jnew("org/wltea/analyzer/example/IKCWS")
    outRef <- .jcall(ikcws, "S" , "segWords",text,evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}


