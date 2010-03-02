.onLoad <- function(...) {
  ## use .onLoad rather than .First.lib when there is namespace
  ## cordinate of ViewFunWidget
  optOld <- options()
  if (is.null(getOption("widgetCoordinate"))) options(widgetCoordinate=c(400,2))
  if (is.null(getOption("widgetSize"))) options(widgetSize=c(550,700))
  assign("optOld",optOld,env=.rqda)  
  if (interactive()) {
     cat("\nUse 'RQDA()' to start the programe.\n",fill=TRUE)
     RQDA()
   }
}

.onUnload <- function(...){
  options(.rqda$optOld)
}