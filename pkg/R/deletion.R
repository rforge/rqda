list.deleted <- function(type=c("file","code","coding")){
  ## list the tmp deleted file/code/coding
  if (!isIdCurrent(.rqda$qdacon)) print("No project is open!")
  else {
    type <- match.arg(type)
    if (type=="file"){
      ans <- dbGetQuery(.rqda$qdacon, "select name from source where status=0")
    }
    else if (type=="code") {
      ans <- dbGetQuery(.rqda$qdacon, "select name from freecode where status=0")
    }
    else if (type=="coding") {
      ans <- dbGetQuery(.rqda$qdacon, "select seltext from coding where status=0")
    }
  }
  if (nrow(ans)==0) sprintf("No %s is deleted.",type)
  else ans
}



pdelete <- function(type=c("file","code","coding"),ask=FALSE){
  ## permanantly delete all the "deleted" files/codes/codings (those with status==0)
  if (!isIdCurrent(.rqda$qdacon)) {
    print("No project is open!")
  }  else {
    type <- match.arg(type)
    del <- list.deleted(type)
    if (!is.data.frame(del)) {
      print("Nothing to clear.")
    } else {
      if (ask) {
        del <- select.list(del[,1],multiple=TRUE)
      } else del <- del[,1]
      if (type=="file"){
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from source where status=0 AND name in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
      } else if (type=="code"){
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from freecode where status=0 AND name in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
      } else if (type=="coding") {
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from coding where status=0 AND seltext in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
      }
    }
  }
}




undelete <- function(type=c("file","code")){
  ## undelete all the "deleted" files/codes (set the status back to 1)
  if (!isIdCurrent(.rqda$qdacon)) {
    print("No project is open!")
  }  else {
    type <- match.arg(type)
    del <- list.deleted(type)
    if (!is.data.frame(del)) {
      print("Nothing to clear.")
    } else {
      del <- select.list(del[,1],multiple=TRUE)
      if (del != "") {
        ## if del is "", then the user click cancel, no need to proceed.
        if (type=="file"){
          ans <- dbGetQuery(.rqda$qdacon, sprintf("update source set status=1 where status=0 AND name in (%s)",
                                                  paste(paste("'",del,"'",sep=""),collapse=",")))
          assign("currentFid",integer(0),envir=.rqda)
          assign("currentFile",character(0),envir=.rqda)
          FileNamesUpdate(FileNamesWidget=.rqda$.fnames_rqda)
        } else if (type=="code"){
          ans <- dbGetQuery(.rqda$qdacon, sprintf("update freecode set status=1 where status=0 AND name in (%s)",
                                                  paste(paste("'",del,"'",sep=""),collapse=",")))
          assign("currentCid",integer(0),envir=.rqda)
          assign("currentCode",character(0),envir=.rqda)
          CodeNamesUpdate(CodeNamesWidget=.rqda$.codes_rqda)
          ## update "codes_index" "currentCid"  "currentCode"
        }
        ## else if (type=="coding") {
        ## ans <- dbGetQuery(.rqda$qdacon, sprintf("update coding set status=1 where status=0 AND seltext in (%s)",
        ##                                          paste(paste("'",del,"'",sep=""),collapse=",")))
        ## should update some info?
        ## may be should pay more attention to this function
        ##}
      }
    }
  }
}



