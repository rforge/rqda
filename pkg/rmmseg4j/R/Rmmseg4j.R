## Chinese Word Segmentation

.onAttach <- function(...) {
    .jinit(system.file("plugins","Rmmseg4j.jar",package="rmmseg4j"))
}

mmseg4j <- function (text, method = c("complex", "maxword"))
{
    ## the plugins are from http://code.google.com/p/mmseg4j/
    ## this one seems most meaningful
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
