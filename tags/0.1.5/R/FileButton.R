ImportFileButton <- function(label="Import", container,...)
{
  gbutton(label, contain=container, handler=function(h,...){
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      path <- gfile(type="open",filter=list("text files" = list(mime.types = c("text/plain")),
              "All files" = list(patterns = c("*"))))
      if (path!=""){
        Encoding(path) <- "UTF-8" ## have to convert, otherwise, can not find the file.
        ImportFile(path,con=.rqda$qdacon)
      }
    }
  }
          )
}


DeleteFileButton <- function(label="Delete", container,...){
  gbutton(label,contain=container,handler=function(h,...)
          {
            if (is_projOpen(env=.rqda,conName="qdacon") & length(svalue(.rqda$.fnames_rqda))!=0) {
              ## if the project open and a file is selected, then continue the action
              del <- gconfirm("Really delete the file?",icon="question")
              if (isTRUE(del)) {
                con <- .rqda$qdacon
                SelectedFile <- svalue(.rqda$.fnames_rqda)
                Encoding(SelectedFile) <- "UTF-8"
                dbGetQuery(.rqda$qdacon, sprintf("update source set status=0 where name='%s'",SelectedFile))
                ## set the status of the selected file to 0
                FileNamesUpdate()
              }
            }
          },
          action=list(env=.rqda,conName="qdacon")
          )
}

ViewFileButton <-  function(label="Open", container,...){
  gbutton(label,contain=container,h=function(h,...){
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      if (length(svalue(.rqda$.fnames_rqda))==0){gmessage("Select a file first.",icon="error",con=TRUE)}
      else {
        tryCatch(dispose(.rqda$.root_edit),error=function(e) {})
        ## notice the error handler
        assign(".root_edit",gwindow(title=svalue(.rqda$.fnames_rqda), parent=c(370,10),width=600,height=600),env=.rqda)
        .root_edit <- get(".root_edit",.rqda)
        assign(".openfile_gui",gtext(container=.root_edit,font.attr=c(sizes="large")),env=.rqda)
        content <- dbGetQuery(.rqda$qdacon, sprintf("select file from source where name='%s'",svalue(.rqda$.fnames_rqda)))[1,1] 
        Encoding(content) <- "UTF-8" ## so it display correct in the gtext widget
        ## turn data.frame to 1-length character.
        W <- get(".openfile_gui",.rqda)
        add(W,content,font.attr=c(sizes="large"))
        slot(W,"widget")@widget$SetEditable(FALSE)
        ## make sure it is read only file in the text window.
      }
    }
  }
          )
}


File_MemoButton <- function(label="F-Memo", container=.files_button,FileWidget=.fnames_rqda,...){
  ## memo of selected file.
  gbutton(label, contain=container, handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      selectedFN <- svalue(FileWidget) ## svalue(.fnames_rqda) is the name of selected file.
      if (length(selectedFN)==0){
        ## if no file is selected, then no need to memo.
        gmessage("Select a file first.",icon="error",con=TRUE)
      }
      else {
        tryCatch(dispose(.rqda$.filememo),error=function(e) {})
        ## Close the open file memo first, then open a new one
        ## .filememo is the container of .fmemocontent,widget for the content of memo
        assign(".filememo",gwindow(title=paste("File Memo",selectedFN,sep=":"),
                                   parent=c(370,10),width=600,height=400),env=.rqda)
        .filememo <- .rqda$.filememo
        .filememo2 <- gpanedgroup(horizontal = FALSE, con=.filememo)
        ## use .filememo2, so can add a save button to it.
        gbutton("Save memo",con=.filememo2,handler=function(h,...){
          ## send the new content of memo back to database
          newcontent <- svalue(W)
          Encoding(newcontent) <- "UTF-8"
          newcontent <- enc(newcontent) ## take care of double quote.
          dbGetQuery(.rqda$qdacon,sprintf("update source set memo='%s' where name='%s'",newcontent,selectedFN))
                                 ## have to quote the character in the sql expression
        }
                )
        assign(".fmemocontent",gtext(container=.filememo2,font.attr=c(sizes="large")),env=.rqda)
        prvcontent <- dbGetQuery(.rqda$qdacon, sprintf("select memo from source where name='%s'",svalue(FileWidget)))[1,1]
        ## [1,1]turn data.frame to 1-length character. Existing content of memo
        if (is.na(prvcontent)) prvcontent <- ""
        Encoding(prvcontent) <- "UTF-8" ## important
        W <- .rqda$.fmemocontent
        add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
        ## push the previous content to the widget.
      }
    }
  }
          )
}



File_RenameButton <- function(label="Rename", container=.files_button,FileWidget=.fnames_rqda,...)
{
  ## rename of selected file.
  gbutton(label, contain=container, handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      selectedFN <- svalue(FileWidget)
      if (length(selectedFN)==0){
        gmessage("Select a file first.",icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewFileName <- ginput("Enter new file name. ", icon="info")
        Encoding(NewFileName) <- "UTF-8"
        ## otherwise, R transform it into local Encoding rather than keep it as UTF-8
        ## Newfilename <- iconv(codename,from="UTF-8") ## now use UTF-8 for SQLite data set.
        ## update the name in source table by a function
        rename(selectedFN,NewFileName,"source")
        ## (name is the only field should be modifed, as other table use fid rather than name)
      }
    }
  }
          )
}


