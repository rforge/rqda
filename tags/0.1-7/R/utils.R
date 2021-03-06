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

enc <- function(x,encoding="UTF-8") {
  ## replace " with two '. to make insert smoothly.
  ## encoding is the encoding of x (character vector).
  Encoding(x) <- encoding
  x <- gsub("'", "''", x)
  if (Encoding(x)!="UTF-8") {
    x <- iconv(x,to="UTF-8")
  }
  x
}

OrderByTime <- function(date,decreasing = FALSE)
{
  ## return tbe permutation of the date which is get by sql "select date from ..."
  ## see order for the meaning of permutation. It can be used as index to sort vector or date frame
  ##   if (getRversion()<"2.8.0"){
  ##     permutation <- ifelse(decreasing,1:length(date),length(date):1)
  ##     ## should rewrite it when project merge is provided.
  ##   } else{
  ## Work for R.2.8.0 or above for Dateclass,so convert to character
  oldLCTIME<- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME","C")
  on.exit(Sys.setlocale("LC_TIME",oldLCTIME))
  Newdate <- as.character(strptime(date, "%a %b %d %H:%M:%S %Y"))
  permutation <- order(Newdate,decreasing = decreasing)
  ##  }
}
## dd<- dbGetQuery(.rqda$qdacon,"select date from source")$date
## sort(dd) == dd[order(dd)] ## but the order is not correct.
## dd[OrderByTime(dd)]


MemoWidget <- function(prefix,widget,dbTable){
  ## prefix of window tile. E.g. "Code" ->  tile of gwindow becomes "Code Memo:"
  ## widget of the F-cat/C-cat list, such as widget=.rqda$.fnames_rqda
  
  if (is_projOpen(env=.rqda,"qdacon")) {
      Selected <- svalue(widget)
      if (length(Selected)==0){
        gmessage("Select first.",icon="error",con=TRUE)
      }
      else {
        tryCatch(eval(parse(text=sprintf("dispose(.rqda$.%smemo)",prefix))),error=function(e) {})
        assign(sprintf(".%smemo",prefix),gwindow(title=sprintf("%s Memo:%s",prefix,Selected),
                                   parent=c(395,10),width=600,height=600),env=.rqda)
        assign(sprintf(".%smemo2",prefix),
               gpanedgroup(horizontal = FALSE, con=get(sprintf(".%smemo",prefix),env=.rqda)),
               env=.rqda)
        gbutton("Save Memo",con=get(sprintf(".%smemo2",prefix),env=.rqda),handler=function(h,...){
          newcontent <- svalue(W)
          ## Encoding(newcontent) <- "UTF-8"
          newcontent <- enc(newcontent,encoding="UTF-8") ## take care of double quote.
          ## Encoding(Selected) <- "UTF-8"
          Selected <- enc(Selected,encoding="UTF-8")
          dbGetQuery(.rqda$qdacon,sprintf("update %s set memo='%s' where name='%s'",dbTable,newcontent,Selected))
        }
                )## end of save memo button
        tmp <- gtext(container=get(sprintf(".%smemo2",prefix),env=.rqda))
        font <- pangoFontDescriptionFromString("Sans 10")
        gtkWidgetModifyFont(tmp@widget@widget,font)## set the default fontsize
        assign(sprintf(".%smemoW",prefix),tmp,env=.rqda)
        prvcontent <- dbGetQuery(.rqda$qdacon, sprintf("select memo from %s where name='%s'",dbTable,Selected))[1,1]
        if (is.na(prvcontent)) prvcontent <- ""
        Encoding(prvcontent) <- "UTF-8"
        W <- get(sprintf(".%smemoW",prefix),env=.rqda)
        ## add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
        add(W,prvcontent,do.newline=FALSE)
      }
    }
  }

## summary coding information
GetCodingTable <- function(){
  ## test when any table is empty
  ## http://archives.postgresql.org/pgsql-sql/2004-01/msg00160.php
  if ( isIdCurrent(.rqda$qdacon)) {
   ## Codings <- dbGetQuery(.rqda$qdacon,"select freecode.name as codename, freecode.id as cid, 
   ##         coding.cid as cid2,coding.fid as fid,source.id as fid2, source.name as filename,
   ##         coding.selend - coding.selfirst as CodingLength,coding.selend, coding.selfirst
   ##         from coding, freecode, source 
   ##         where coding.status==1 and freecode.id=coding.cid and coding.fid=source.id")
   Codings <- dbGetQuery(.rqda$qdacon,"select coding.cid, coding.fid, freecode.name as codename, source.name as filename,
                                       coding.selfirst as index1, coding.selend as index2,
                                       coding.selend - coding.selfirst as CodingLength
                                      from coding left join freecode on (coding.cid=freecode.id)
                                                  left join source on (coding.fid=source.id) 
                                      where coding.status==1 and source.status=1 and freecode.status=1")

    if (nrow(Codings)!=0){
      Encoding(Codings$codename) <- Encoding(Codings$filename) <- "UTF-8"
    }
   ## if (!all (all.equal(Codings$cid,Codings$cid2),all.equal(Codings$fid,Codings$fid2))){
   ##   stop("Errors!") ## check to make sure the sql is correct
   ## }
    Codings
  } else cat("Open a project first.\n")
}

SummaryCoding <- function(byFile=FALSE,...){
  if ( isIdCurrent(.rqda$qdacon)) {
    Codings <- GetCodingTable()
    if (nrow(Codings)>0){
      NumOfCoding <- table(Codings$codename,...) ## how many coding for each code
      AvgLength <- tapply(Codings$CodingLength,Codings$codename,FUN=mean,...) # Average of words for each code
      NumOfFile <- tapply(Codings$fid,Codings$codename,FUN=length,...) # Number of files for each code
      if (byFile){
        CodingOfFile <- tapply(Codings$codename,Codings$filename,FUN=table,...) # summary of codings for each file
      } else CodingOfFile <- NULL
      ans <- list(NumOfCoding=NumOfCoding,AvgLength=AvgLength,NumOfFile=NumOfFile,CodingOfFile=CodingOfFile)
      class(ans) <- "SummaryCoding"
      ans
    } else {
      cat("No coding.\n")
    }
  } else {
    cat("Open a project first.\n")
  }
}

print.SummaryCoding <- function(x,...){
  class(x)
  if (!is.null(x$CodingOfFile)){
    cat("----------------\n")
    cat("Number of codings for each file.\n")
    print(x$CodingOfFile)
  }
  cat("----------------\n")
  cat("Number of codings for each code.\n")
  print(x$NumOfCoding)
  cat("----------------\n")
  cat("Average number of words assciated with each code.\n\n")
  print(x$AvgLength)
  cat("----------------\n")
  cat("Number of files associated with each code.\n\n")
  print(x$NumOfFile)
}


SearchFiles <- function(pattern,content=FALSE,Widget=NULL,is.UTF8=FALSE){
##SearchFiles("file like '%新民晚报%'")
##SearchFiles("name like '%物权法%'")
##SearchFiles("file like '%新民晚报%'",Widget=.rqda$.fnames_rqda)
  if ( isIdCurrent(.rqda$qdacon)) {
if(!is.UTF8){
pattern <- iconv(pattern,to="UTF-8")
}
Encoding(pattern) <- "unknown"
if (content){
ans <- dbGetQuery(.rqda$qdacon,sprintf("select id, name,file from source where status==1 and %s",pattern))
} else {
ans <- dbGetQuery(.rqda$qdacon,sprintf("select id, name from source where status==1 and %s",pattern))
}
if (nrow(ans)>0) Encoding(ans$name) <- "UTF-8"
if (!is.null(ans$file)) Encoding(ans$file) <- "UTF-8"
if (!is.null(Widget)) eval(substitute(widget[] <- ans$name,list(widget=quote(Widget))))
invisible(ans)
  } else cat("Open a project first.\n")
}

## select <- function(x,multiple=TRUE,title=NULL,...){
## ## select a method for selecting items conditional on the OS, to maxizied the chance of GUI-style of selection.
## ## use as replacement of  select.list.
##   if (.Platform$OS.type == "unix" && capabilities("tcltk") && capabilities("X11"))
##     {
##       ans <- tcltk::tk_select.list(x,multiple=multiple,title=title,...)
##     } else {
##       ans <- select.list(x,multiple=multiple,title=title,...)
##     }
##   return(list(selected=ans))
## }


RunOnSelected <- function(x,multiple=TRUE,expr,enclos,title=NULL,...){
  if (is.null(title)) title <- ifelse(multiple,"Select one or more","Select one")
  g <- gwindow(title=title,wid=250,heigh=600,parent=c(395, 10))
  x1<-ggroup(FALSE,con=g)
  ##x1@widget@widget$parent$parent$parent$SetTitle(title)
  ##x1@widget@widget$parent$parent$parent$SetDefaultSize(200, 500)
  x2<-gtable(x,multiple=multiple,con=x1,expand=TRUE)
  gbutton("Cancel",con=x1,handler=function(h,...){
    dispose(x1)
  })
  gbutton("OK",con=x1,handler=function(h,...){
    Selected <- svalue(x2)
    if (Selected!=""){
    eval(h$action$expr,env=pairlist(Selected=Selected),enclos=h$action$enclos)
    ## evaluate expr in env
    ## Variable Selected will be found in env
    ## because env is parilist and there are variables not there, which will be found in enclos.
    dispose(g)
   } else gmessage("Select before Click OK.\n",con=TRUE,icon="error")
  },
          action=list(expr=substitute(expr),enclos=enclos)
          )
  invisible()
}


gselect.list <- function(list,multiple=TRUE,title=NULL,width=200, height=500,...){
  ## gtk version of select.list()
  ## Thanks go to John Verzani for his help.
  title <- ifelse(multiple,"Select one or more","Select one")
  
  helper <- function(){
    ans<-new.env()
    x1<-ggroup(horizontal=FALSE) # no parent container here
    x2<-gtable(list,multiple=multiple,con=x1,expand=TRUE)
    gtkWidgetSetSizeRequest(x1@widget@widget, width=width, height=height)
    ret <- gbasicdialog(title=title,widget=x1,handler=function(h,...){
      value <- svalue(x2)
      assign("selected",value,env=h$action$env)
      dispose(x1)
    },action=list(env=ans))
    ans
  }## end helper function
  items <- helper()$selected
  if (is.null(items)) items <- ""
  items
}

## intersect2 <- function(x) {
##   if ((n<-length(x))>1) {
##     x[[n-1]] <- intersect(x[[n]],x[[n-1]])
##     x[n] <- NULL
##     Recall(x)
##   } else { x[[1]] }
## }
##x<-list(1:3,3:5,6:3)
##intersect2(x)

GetCaseId <- function(fid=GetFileId(),nFiles=FALSE){
  ## if (caseName){
  if (nFiles) {
    ## ans <-  dbGetQuery(.rqda$qdacon,sprintf(" select name,id from cases where status=1 and id in (select caseid from caselinkage where status=1 and fid in (%s) group by caseid )",paste(shQuote(fid),collapse=",")))
    ## if (nrow(ans)>0) Encoding(ans$name) <- "UTF-8"
    ans <- dbGetQuery(.rqda$qdacon,sprintf("select caseid, count(caseid) as nFiles from caselinkage where status=1 and fid in (%s) group by caseid",paste(shQuote(fid),collapse=",")))
  } else {
    ans <- dbGetQuery(.rqda$qdacon,sprintf("select caseid from caselinkage where status=1 and fid in (%s) group by caseid",paste(shQuote(fid),collapse=",")))$caseid
  }
  ## attr(ans,"caseName") <- caseName
  ## class(ans) <- c("data.frame","CaseId")
  ans
}

GetCaseName <- function(caseId=GetCaseId(nFiles=FALSE)){
  ans <-  dbGetQuery(.rqda$qdacon,sprintf("select name from cases where status=1 and id in (%s)",paste(shQuote(caseId),collapse=",")))$name
  if (length(ans)>0) Encoding(ans) <- "UTF-8"
  ans
}

RQDAQuery <- function(sql){
  ans <- dbGetQuery(.rqda$qdacon,sql)
  ans
}

## ShowSubset <- function(name=NULL,widget=NULL,...){
##   UseMethod("ShowSubset")
## }
## ShowSubset.default <- function(name=NULL,widget=NULL,...){
##   widget[] <- name
## }


ShowSubset <- function(x){
## change name from PushBack to ShowSubset()
 if (inherits(x,"CaseAttr")) tryCatch(.rqda$.CasesNamesWidget[] <- x$case, error = function(e) {})
 if (inherits(x,"FileAttr")) tryCatch(.rqda$.fnames_rqda[] <- x$file, error = function(e) {})
 if (inherits(x,"CaseId") && isTRUE(attr(x,"caseName"))) tryCatch(.rqda$.CasesNamesWidget[] <- x$name, error = function(e) {})
}
