## Chinese Word Segmentation
CWS <- function (text,stpwords=FALSE)
{
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    if (isTRUE(stpwords)) zj <- "true" else zj <- "false"
    .jinit(system.file("plugins","ChineseWordSegmentation.jar",package="RQDAtm"))
    ## the plugins are from http://code.google.com/p/imdict-chinese-analyzer/
    hjw <- .jnew("org.apache.lucene.analysis.cn.hzfc")
    outRef <- .jcall(hjw, "S" , "txtMethod",text,zj, evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}
