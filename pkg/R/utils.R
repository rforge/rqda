OrderByTime <- function(date,decreasing = FALSE){
## return tbe permutation of the date which is get by sql "select date from ..."
## see order for the meaning of permutation. It can be used as index to sort vector or date frame
oldLCTIME<- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME","C")
on.exit(Sys.setlocale("LC_TIME",oldLCTIME))
Newdate <- strptime(date, "%a %b %d %H:%M:%S %Y")
permutation <- order(Newdate,decreasing = decreasing)
}
## dd<- dbGetQuery(.rqda$qdacon,"select date from source")$date
## sort(dd) == dd[order(dd)] ## but the order is not correct.
## dd[OrderByTime(dd)]


setEncoding <- function(encoding="unknown"){
  ## specify what encoding is used in the imported files.
  .rqda$encoding <- encoding
}


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
                                   parent=c(395,10),width=600,height=400),env=.rqda)
        assign(sprintf(".%smemo2",prefix),
               gpanedgroup(horizontal = FALSE, con=get(sprintf(".%smemo",prefix),env=.rqda)),
               env=.rqda)
        gbutton("Save Memo",con=get(sprintf(".%smemo2",prefix),env=.rqda),handler=function(h,...){
          newcontent <- svalue(W)
          Encoding(newcontent) <- "UTF-8"
          newcontent <- enc(newcontent) ## take care of double quote.
          Encoding(Selected) <- "UTF-8"
          dbGetQuery(.rqda$qdacon,sprintf("update %s set memo='%s' where name='%s'",dbTable,newcontent,Selected))
        }
                )## end of save memo button
        assign(sprintf(".%smemoW",prefix),gtext(container=get(sprintf(".%smemo2",prefix),env=.rqda),
                                              font.attr=c(sizes="large")),env=.rqda)
        prvcontent <- dbGetQuery(.rqda$qdacon, sprintf("select memo from %s where name='%s'",dbTable,Selected))[1,1]
        if (is.na(prvcontent)) prvcontent <- ""
        Encoding(prvcontent) <- "UTF-8"
        W <- get(sprintf(".%smemoW",prefix),env=.rqda)
        add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
      }
    }
  }
