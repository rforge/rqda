## Chinese Word Segmentation
smartcn <- function (text)
{
    if (length(text)!= 1) stop("text must be length-1 character vector.")
    .jinit(system.file("plugins","rsmartcn.jar",package="rsmartcn"))
    smartcn <- .jnew("rsmartcn.rsmartcn")
    outRef <- .jcall(smartcn, "S" , "textMethod", text, evalString = FALSE)
    ans <- .jstrVal(outRef)
    ans
}
