rqdameta <-function(){
assign(".rqda",new.env(),.GlobalEnv)
.rqda$codes_index <- data.frame(name=character(0),id=integer(0))
.rqda$files_index <- data.frame(name=character(0),id=integer(0))
}

.First.lib <- function(...) {
## .rqda environment MUST be created.
#library(gWidgetsRGtk2)
#library(RSQLite)
rqdameta()
cat("\nUse RQDA() to start the programe.\n",fill=TRUE)
cat("Do NOT remove the .rdqa environment in .GlobalEnv.",fill=TRUE)
cat("If you haved deleted it, You can run rdqameta() manually,\nand then start RQDA() again.",fill=TRUE)
}
