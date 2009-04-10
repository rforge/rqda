rename <- function(from,to,table=c("source","freecode","cases","codecat","filecat","journal")){
  ## rename name field in table source and freecode (other tables can be added futher)
  ## source is the file name, freecode is the free code name
  table <- match.arg(table)
  if (to!=""){ ## if to is "", makes no sense to rename
##     dbGetQuery(.rqda$qdacon, sprintf("update %s set name = %s where name == %s ",
##                                      table,
##                                      paste("'",to,"'",collapse="",sep=""),
##                                      paste("'",from,"'",collapse="",sep="")
##                                      )
    exists <- dbGetQuery(.rqda$qdacon, sprintf("select * from %s where name == '%s' ",table, to))
    ## should check it there is any dupliation in the table
    if (nrow(exists) > 0) {
      gmessage("The new name is duplicated. Please use another new name.",container=TRUE)
    } else {
      dbGetQuery(.rqda$qdacon, sprintf("update '%s' set name = '%s' where name == '%s' ",table, to, from))
    }
  }
}
