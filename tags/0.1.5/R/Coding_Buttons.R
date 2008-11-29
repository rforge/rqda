AddCodeButton <- function(label="Add"){
  gbutton(label,
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              codename <- ginput("Enter new code. ", icon="info")
              Encoding(codename) <- "UTF-8"
              addcode(codename)
              CodeNamesUpdate()
            }
          }
        )
}


DeleteCodeButton <- function(){
  gbutton(" Delete ",
          handler=function(h,...)
          {
            if (is_projOpen(env=.rqda,conName="qdacon") &
                length(svalue(.rqda$.codes_rqda))!=0) {
              ## if project is open and one code is selected,then continue
              del <- gconfirm("Really delete the code?",icon="question")
              if (isTRUE(del)){
                SelectedCode <- svalue(.rqda$.codes_rqda)
                Encoding(SelectedCode) <- "UTF-8"
                dbGetQuery(.rqda$qdacon,sprintf("update freecode set status=0 where name=='%s'",SelectedCode))
                ## set status in table freecode to 0
                CodeNamesUpdate()
              }
                                 }
          }
          )
}

RetrievalButton <- function(label){
  gbutton(label,
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              retrieval()
            }
          }
          )
}


HL_ALLButton <- function(){
  gbutton("HL ALL",
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              con <- .rqda$qdacon
              SelectedFile <- svalue(.rqda$.root_edit)
              Encoding(SelectedFile) <- "UTF-8"
              currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
              W <- tryCatch( get(h$action$widget,.rqda),
                            error=function(e) {}
                            )
              if (length(currentFid)!=0 & !is.null(W)) {
                ## if fid is integer(0), then there is no file selected and open
                ## if W is null, then there is no valid widget. No need to HL.
                ## Though W may be expired, but ClearMark and HL will take care of the issue.
                mark_index <-
                  dbGetQuery(con,sprintf("select selfirst,selend,status from coding where fid=%i",currentFid))
                ## only select thoses with the open_file and not deleted (status=1).
                ClearMark(W ,0 , max(mark_index$selend))
                HL(W,index=mark_index[mark_index$status==1,1:2])
              }
            }
          },
          action=list(widget=".openfile_gui")
          )
}



Mark_Button<-function(){
  gbutton("Mark",
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              con <- .rqda$qdacon
                                   tryCatch({
                                     ans <- mark(get(h$action$widget,env=.rqda)) ## can change the color
                                     if (ans$start != ans$end){ 
                                       ## when selected no text, makes on sense to do anything.
                                       SelectedCode <- svalue(.rqda$.codes_rqda)
                                       Encoding(SelectedCode) <- "UTF-8"
                                       currentCid <-  dbGetQuery(con,sprintf("select id from freecode where name=='%s'",
                                                                             SelectedCode))[,1]
                                       SelectedFile <- svalue(.rqda$.root_edit)
                                       Encoding(SelectedFile) <- "UTF-8"
                                       currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",
                                                                             SelectedFile))[,1]
                                       DAT <- data.frame(cid=currentCid,fid=currentFid,seltext=ans$text,
                                                         selfirst=ans$start,selend=ans$end,status=1,
                                                         owner=.rqda$owner,date=date(),memo="")
                                       success <- dbWriteTable(.rqda$qdacon,"coding",DAT,row.name=FALSE,append=TRUE)
                                       if (!success) gmessage("Fail to write to database.")
                                     }
                                   },error=function(e){}
                                            )
            }
          },
          action=list(widget=".openfile_gui")
          )
}


Unmark_Button <- function(){
  gbutton("Unmark",
                               handler=function(h,...) {
                                 if (is_projOpen(env=.rqda,conName="qdacon")) {
                                   con <- .rqda$qdacon
                                   W <- tryCatch( get(h$action$widget,env=.rqda),
                                                 error=function(e){}
                                                 )
                                   ## get the widget for file display. If it does not exist, then return NULL.
                                   sel_index <- tryCatch(sindex(W),error=function(e) {})
                                   ## if the not file is open, unmark doesn't work.
                                   if (!is.null(sel_index)) {
                                     SelectedCode <- svalue(.rqda$.codes_rqda)
                                     Encoding(SelectedCode) <- "UTF-8"
                                     currentCid <-  dbGetQuery(.rqda$qdacon,
                                                               sprintf("select id from freecode where name=='%s'",
                                                                       SelectedCode))[,1]
                                     SelectedFile <- svalue(.rqda$.root_edit)
                                     Encoding(SelectedFile) <- "UTF-8"
                                     currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",
                                                                           SelectedFile))[,1]
codings_index <-  dbGetQuery(con,sprintf("select rowid, cid, fid, selfirst, selend from coding where cid==%i and fid==%i",
                                         currentCid, currentFid))
                                     ## should only work with those related to current code and current file.
                                     rowid <- codings_index$rowid[(codings_index$selfirst  >= sel_index$startN) &
                                                                  (codings_index$selend  <= sel_index$endN)]
                                     if (is.numeric(rowid)) for (j in rowid) {
                                       dbGetQuery(con,sprintf("update coding set status=0 where rowid=%i", j))  }
                                     ## better to get around the loop by sqlite condition expression.
                                     ClearMark(W,min=sel_index$startN,max=sel_index$endN)
                                     ## This clear all the marks in the gtext window,
                                     ## even for the non-current code. can improve.
                                   }
                                 }
                               },
          action=list(widget=".openfile_gui")
          )
}




CodeMemoButton <- function(label="C-Memo",...){
  gbutton(label, handler=function(h,...) {
    ## code memo: such as meaning of code etc.
    if (is_projOpen(env=.rqda,"qdacon")) {
      currentCode <- svalue(.rqda$.codes_rqda)
      if (length(currentCode)==0){
        gmessage("Select a code first.",icon="error",con=TRUE)
      }
      else {
        tryCatch(dispose(.rqda$.codememo),error=function(e) {})
        assign(".codememo",gwindow(title=paste("Code Memo",.rqda$currentCode,sep=":"),
                                   parent=c(370,10),width=600,height=400),env=.rqda)
        .codememo <- .rqda$.codememo
        .codememo2 <- gpanedgroup(horizontal = FALSE, con=.codememo)
        gbutton("Save Code Memo",con=.codememo2,handler=function(h,...){
          newcontent <- svalue(W)
          Encoding(newcontent) <- "UTF-8"
          newcontent <- enc(newcontent) ## take care of double quote.
          Encoding(currentCode) <- "UTF-8"
          dbGetQuery(.rqda$qdacon,sprintf("update freecode set memo='%s' where name='%s'",newcontent,currentCode))
        }
                )## end of save memo button
        assign(".cmemocontent",gtext(container=.codememo2,font.attr=c(sizes="large")),env=.rqda)
        prvcontent <- dbGetQuery(.rqda$qdacon, sprintf("select memo from freecode where name='%s'",currentCode))[1,1]
        if (is.na(prvcontent)) prvcontent <- ""
        Encoding(prvcontent) <- "UTF-8"
        W <- .rqda$.cmemocontent
        add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
      }
    }
  }
          )
}






CodingMemoButton <- function(label="C2Memo")
{
  gbutton(label, handler= function(h,...){
    con <- .rqda$qdacon
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      W <- tryCatch( get(".openfile_gui",env=.rqda), error=function(e){})
      ## get the widget for file display. If it does not exist, then return NULL.
      sel_index <- tryCatch(sindex(W),error=function(e) {}) ## if the not file is open, it doesn't work.
      if (is.null(sel_index)) {gmessage("Open a file first!",con=TRUE)}
      else {
        SelectedCode <- svalue(.rqda$.codes_rqda); Encoding(SelectedCode) <- "UTF-8"
        if (length(SelectedCode)==0) gmessage("Select a code first!") else {
          currentCid <-  dbGetQuery(con,sprintf("select id from freecode where name=='%s'",SelectedCode))[,1]
          SelectedFile <- svalue(.rqda$.fnames_rqda); Encoding(SelectedFile) <- "UTF-8"
          currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
          codings_index <-  dbGetQuery(con,sprintf("select rowid, cid, fid, selfirst, selend from coding where
                                                   cid==%i and fid==%i ",currentCid, currentFid))
          ## should only work with those related to current code and current file.
          rowid <- codings_index$rowid[(codings_index$selfirst  >= sel_index$startN) &
                                       (codings_index$selfirst  <= sel_index$startN + 4) &
                                       (codings_index$selend  <= sel_index$endN)&
                                       (codings_index$selend  >= sel_index$endN - 4)
                                       ] ## determine which one is the current text chunk?
          if (length(rowid)!= 1) {gmessage("Select the exact coding first!", con=TRUE)}
          else {
            ##  open a widget for memo, and take care of the save memo function
            tryCatch(dispose(.rqda$.codingmemo),error=function(e) {})
            ## Close the coding memo first, then open a new one
            assign(".codingmemo",gwindow(title=paste("Coding Memo for",SelectedCode,sep=":"),
                                         parent=c(370,10),width=600,height=400
                                         ), env=.rqda
                   )
            .codingmemo <- get(".codingmemo",env=.rqda)
            .codingmemo2 <- gpanedgroup(horizontal = FALSE, con=.codingmemo)
            gbutton("Save Coding Memo",con=.codingmemo2,handler=function(h,...){
              newcontent <- svalue(W)
              Encoding(newcontent) <- "UTF-8"
              newcontent <- enc(newcontent) ## take care of double quote.
              dbGetQuery(con,sprintf("update coding set memo='%s' where rowid=%i",newcontent,rowid))
            }
                    )## end of save memo button
            assign(".cdmemocontent",gtext(container=.codingmemo2,font.attr=c(sizes="large")),env=.rqda)
            prvcontent <- dbGetQuery(con, sprintf("select memo from coding where rowid=%i",rowid))[1,1]
            if (is.na(prvcontent)) prvcontent <- ""
            Encoding(prvcontent) <- "UTF-8"
            W <- get(".cdmemocontent",env=.rqda)
            add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
          }
        }
      }
    }
  }
          )
}



FreeCode_RenameButton <- function(label="Rename",CodeNamesWidget=.codes_rqda,...)
{
  ## rename of selected file.
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      selectedCodeName <- svalue(CodeNamesWidget)
      if (length(selectedCodeName)==0){
        gmessage("Select a code first.",icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewCodeName <- ginput("Enter new code name. ", icon="info")
        Encoding(NewCodeName) <- "UTF-8"
        ## update the name in source table by a function
        rename(selectedCodeName,NewCodeName,"freecode")
        ## (name is the only field should be modifed, as other table use ID rather than name)
      }
    }
  }
          )
}

