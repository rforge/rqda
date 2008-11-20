Proj_MemoButton <- function(label="Porject Memo",container=.proj_gui,...){
#### Each button a separate function -> more easy to debug, and the main function root_gui is shorter.
### The memo in dataset is UTF-8
  ## label of button
  ## name of contaianer or TRUE
  proj_memo <- gbutton(label, contain=container, handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## use enviroment, so you can refer to the same object easily, this is the beauty of environment
      ## if project is open, then continue
      tryCatch(dispose(.rqda$.projmemo),error=function(e) {})
      ## Close the open project memo first, then open a new one
      ## .projmemo is the container of .projmemocontent,widget for the content of memo
      assign(".projmemo",gwindow(title="Project Memo", parent=c(370,10),width=600,height=400),env=.rqda)
      .projmemo <- get(".projmemo",.rqda)
      .projmemo2 <- gpanedgroup(horizontal = FALSE, con=.projmemo)
      ## use .projmemo2, so can add a save button to it.
      gbutton("Save memo",con=.projmemo2,handler=function(h,...){
        ## send the new content of memo back to database
        newcontent <- svalue(W)
        Encoding(newcontent) <- "UTF-8"
        newcontent <- enc(newcontent) ## take care of double quote.
        dbGetQuery(.rqda$qdacon,sprintf("update project set memo='%s' where rowid==1", ## only one row is needed
                                        newcontent)
                   ## have to quote the character in the sql expression
                   )
      }
              )## end of save memo button
      assign(".projmemocontent",gtext(container=.projmemo2,font.attr=c(sizes="large")),env=.rqda)
      prvcontent <- dbGetQuery(.rqda$qdacon, "select memo from project")[1,1]
      ## [1,1]turn data.frame to 1-length character. Existing content of memo
      if (length(prvcontent)==0) {
        dbGetQuery(.rqda$qdacon,"replace into project (memo) values('')")
        prvcontent <- ""
        ## if there is no record in project table, it fails to save memo, so insert sth into it
      }
      W <- .rqda$.projmemocontent
      Encoding(prvcontent) <- "UTF-8"
      add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
      ## do.newline:do not add a \n (new line) at the beginning
      ## push the previous content to the widget.
    }
  }
                       )
}


