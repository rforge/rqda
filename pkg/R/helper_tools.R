list.deleted <- function(type=c("file","code","coding")){
## list the deleted file/code/coding
if (!isIdCurrent(.rqda$qdacon)) print("No project is open!") else {
type <- match.arg(type)
if (type=="file"){
ans <- dbGetQuery(.rqda$qdacon, "select name from source where status=0")
} else if (type=="code"){
ans <- dbGetQuery(.rqda$qdacon, "select name from freecode where status=0")
} else if (type=="coding") {
ans <- dbGetQuery(.rqda$qdacon, "select seltext from coding where status=0")
}
}
if (nrow(ans)==0) sprintf("No %s is deleted.",type) else ans
}

clear <- function(ask=FALSE,type=c("file","code","coding")){
## delete all the "deleted" files/codes/codings (those with status==0)
if (!isIdCurrent(.rqda$qdacon)) print("No project is open!") else {
type <- match.arg(type)
del <- list.deleted(type)
 if (!is.data.frame(del)) print("Nothing to clear.") else {
 if (ask) del <- select.list(del[,1],multiple=TRUE) else del <- del[,1]
if (type=="file"){
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from source where status=0 AND name in (%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
} else if (type=="code"){
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from freecode where status=0 AND name in (%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
} else if (type=="coding") {
ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from coding where status=0 AND seltext in (%s)",
                                paste(paste("'",del,"'",sep=""),collapse=",")))
}}
}
}
