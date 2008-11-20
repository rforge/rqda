.First.lib <- function(...) {
  .rqda <- new.env()
  .rqda$owner <- "default"
  .rqda$BOM <- FALSE
  .rqda$encoding <- "unknown"
  cat("\nUse RQDA() to start the programe.\n",fill=TRUE)
 ## RQDA()
}
