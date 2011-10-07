## Chinese Word Segmentation
mmseg4j <- function (text,method=c("complex"))
{
    ## the plugins are from http://code.google.com/p/mmseg4j/
    ## this one seems most meaningful
    method = match.arg(method)
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","Rmmseg4j.jar",package="rmmseg4j"))
    if (method=="complex") {
        mmseg <- .jnew("Rmmseg4j/Rmmseg")
        outRef <- .jcall(mmseg, "S" , "textMethod",text,evalString = FALSE)
    }
    ans <- .jstrVal(outRef)
    ans
}
