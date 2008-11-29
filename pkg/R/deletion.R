list.deleted <- function(type=c("file","code","case","codecategory","coding")){
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
    } else if (type=="case"){
      ans <- dbGetQuery(.rqda$qdacon, "select name from cases where status=0")
    } else if (type=="codecategory"){
      ans <- dbGetQuery(.rqda$qdacon, "select name from codecat where status=0")
    }
    if (nrow(ans)==0) {
      sprintf("No %s is deleted.",type)
    }  else {
      Encoding(ans[,1]) <- "UTF-8"
      ans
    }
  }
}



pdelete <- function(type=c("file","code","case","codecategory","coding"),ask=FALSE){
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
        fid <- dbGetQuery(.rqda$qdacon, sprintf("select id from source where status=0 AND name in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))[,1]
        if (length(fid)!=0){
       dbGetQuery(.rqda$qdacon, sprintf("delete from coding where fid in (%s)",
                                                paste(paste(fid,sep=""),collapse=",")))
       ## delete associated coding even regardless of their status

        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from source where status=0 AND name in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
   }
      } else if (type=="code"){
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from freecode where status=0 AND name in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
      } else if (type=="coding") {
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from coding where status=0 AND seltext in (%s)",
                                                paste(paste("'",del,"'",sep=""),collapse=",")))
      } else if (type=="case"){
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from cases where status=0 AND name in (%s)",
                                                paste("'",del,"'",collapse=",",sep="")))
        ## and its related caselinkage?
      } else if (type=="codecategory"){
        ans <- dbGetQuery(.rqda$qdacon, sprintf("delete from codecat where status=0 AND name in ('%s')",
                                                paste("'",del,"'",collapse=",",sep="")))
        ## and its related treecode?
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
             FileNamesUpdate(FileNamesWidget=.rqda$.fnames_rqda)
        } else if (type=="code"){
          ans <- dbGetQuery(.rqda$qdacon, sprintf("update freecode set status=1 where status=0 AND name in (%s)",
                                                  paste(paste("'",del,"'",sep=""),collapse=",")))
          CodeNamesUpdate(CodeNamesWidget=.rqda$.codes_rqda)
          ## update Widget
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



