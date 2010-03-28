## part of RQDA project
## by ronggui HUANG

.onAttach <- function(...) {
  ## use .onLoad/.onAttach rather than .First.lib when there is namespace
  ## Refer R news 2003-1 for details about name space
  optOld <- options()
  if (is.null(getOption("widgetCoordinate"))) options(widgetCoordinate=c(400,2))
  ## cordinate of ViewFunWidget
  if (is.null(getOption("widgetSize"))) options(widgetSize=c(550,700))
  options(andMethod=c("overlap","exact","inclusion"))
  assign("optOld",optOld,env=.rqda)
  if (interactive()) {
     cat("\nUse 'RQDA()' to start the programe.\n",fill=TRUE)
     RQDA()
   }
}

.onUnload <- function(...){
  cat("Bye, RQDA is unloaded.\n")
  options(.rqda$optOld)
}
