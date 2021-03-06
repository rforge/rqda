Handler <- function(){
### add handler function for GUIs

  ## handler for Root
  addHandlerUnrealize(.rqda$.root_rqdagui, handler = function(h,...) {
    ## make sure is the project should be closed by issuing a confirm window.
    val <- gconfirm("Really EXIST?\n\nYou can use RQDA() to start this program again.", parent=h$obj)
    if(as.logical(val))
      return(FALSE)             # destroy
    else
      return(TRUE)              # don't destroy
  }
                      )

  ## handler for .fnames_rqda (gtable holding the file names)

  addHandlerClicked(.rqda$.fnames_rqda, handler <- function(h, ...) {
    ## updating the file name list, and update the status of curent selected file.
    if (is_projOpen(env = .rqda, conName = "qdacon", message = FALSE)) {
      FileNamesUpdate(FileNamesWidget=.rqda$.fnames_rqda)
    }
  }
                    )

  addHandlerMouseMotion(.rqda$.fnames_rqda, handler <- function(h,...) {
    if (is_projOpen(env = .rqda, conName = "qdacon", message = FALSE)) {
      FileNamesUpdate(FileNamesWidget=.rqda$.fnames_rqda)
    }
  }
                        )


  addhandlerdoubleclick(.rqda$.fnames_rqda, handler <- function(h,...)
  ##function copied from ViewFileButton handler
  {
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
  }##end of function  copied from ViewFileButton handler
                        )


  ## handler for .codes_rqda

  addHandlerMouseMotion(.rqda$.codes_rqda, handler <- function(h, ...) {
    if (is_projOpen(env = .rqda, conName ="qdacon",message = FALSE)) {
       CodeNamesUpdate(CodeNamesWidget=.rqda$.codes_rqda)
    }
  }
                        )

  addhandlerdoubleclick(.rqda$.codes_rqda,handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon"))  retrieval()
          }
                        )
  
  
  addHandlerClicked(.rqda$.codes_rqda,handler <- function(h,...){
            if (is_projOpen(env=.rqda,conName="qdacon")){
    CodeNamesUpdate(CodeNamesWidget=.rqda$.codes_rqda)
    con <- .rqda$qdacon
    SelectedCode <- currentCode <- svalue(.rqda$.codes_rqda)
    if (length(SelectedCode)!=0) {
    Encoding(SelectedCode) <- Encoding(currentCode) <- "UTF-8"
    currentCid <- dbGetQuery(con,sprintf("select id from freecode where name=='%s'",SelectedCode))[,1]
    SelectedFile <- tryCatch(svalue(.rqda$.root_edit)  ## use root_edit is more reliable
                             ,error=function(e){})
    if (!is.null(SelectedFile)) {
      Encoding(SelectedFile) <- "UTF-8"
      currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
      ## following code: Only mark the text chuck according to the current code.
      tryCatch({
        widget <- get(h$action$marktxtwidget,.rqda)
        ## if widget is not open, then error;which means no need to highlight anything.
        sel_index <-  dbGetQuery(con,sprintf("select selfirst, selend from coding where
                                                   cid==%i and fid==%i and status==1",currentCid, currentFid))
        Maxindex <- dbGetQuery(con, sprintf("select max(selend) from coding where fid==%i", currentFid))[1,1]
        ClearMark(widget,min=0,max=Maxindex)
        if (nrow(sel_index)>0){
          HL(widget,index=sel_index)}
      },error=function(e){}) # end of mark text chuck
    }
  }
  }},action=list(marktxtwidget=".openfile_gui")
                    )


  addHandlerMouseMotion(.rqda$.CasesNamesWidget, handler <- function(h, ...) {
    if (is_projOpen(env = .rqda, conName ="qdacon",message = FALSE)) {
       CaseNamesUpdate(.rqda$.CasesNamesWidget)
    }
  }
                        )
  


  addHandlerClicked(.rqda$.CasesNamesWidget,handler <- function(h,...){
    CaseNamesUpdate(.rqda$.CasesNamesWidget)
    con <- .rqda$qdacon
    SelectedCase <- currentCase <- svalue(.rqda$.CasesNamesWidget)
    if (length(SelectedCase)!=0) {
    Encoding(SelectedCase) <- Encoding(currentCase) <- "UTF-8"
    currentCid <- dbGetQuery(con,sprintf("select id from cases where name=='%s'",SelectedCase))[,1]
    SelectedFile <- tryCatch(svalue(.rqda$.root_edit)  ## use root_edit is more reliable
                             ,error=function(e){})
    if (!is.null(SelectedFile)) {
      Encoding(SelectedFile) <- "UTF-8"
      currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
      ## following code: Only mark the text chuck according to the current code.
      tryCatch({
        widget <- get(h$action$marktxtwidget,.rqda)
        ## if widget is not open, then error;which means no need to highlight anything.
        sel_index <-  dbGetQuery(con,sprintf("select selfirst, selend from caselinkage where
                                                   caseid==%i and fid==%i and status==1",currentCid, currentFid))
        Maxindex <- dbGetQuery(con, sprintf("select max(selend) from caselinkage where fid==%i", currentFid))[1,1]
        ClearMark(widget,min=0,max=Maxindex)
        if (nrow(sel_index)>0){
          HL(widget,index=sel_index)}
      },error=function(e){}) # end of mark text chuck
    }
  }
  },action=list(marktxtwidget=".openfile_gui")
                    )

  addHandlerClicked(.rqda$.CodeCatWidget,handler <- function(h,...){
    UpdateCodeofCatWidget(con=.rqda$qdacon,Widget=.rqda$.CodeofCat)
})

add3rdmousepopupmenu(.rqda$.CasesNamesWidget, CaseNamesWidgetMenu)
## popup menu by right-click on CaseNamesWidget
}

