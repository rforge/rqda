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


  ## handler for .codes_rqda

  addHandlerMouseMotion(.rqda$.codes_rqda, handler <- function(h, ...) {
    if (is_projOpen(env = .rqda, conName ="qdacon",message = FALSE)) {
       CodeNamesUpdate(CodeNamesWidget=.rqda$.codes_rqda)
    }
  }
                        )

  
  
  addHandlerClicked(.rqda$.codes_rqda,handler <- function(h,...){
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
  },action=list(marktxtwidget=".openfile_gui")
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


}

