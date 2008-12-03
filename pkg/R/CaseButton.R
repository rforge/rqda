AddCaseButton <- function(label="ADD"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      CaseName <- ginput("Enter new Case Name. ", icon="info")
      if (CaseName!="") {
        Encoding(CaseName) <- "UTF-8"
        AddCase(CaseName)
        CaseNamesUpdate()
      }
    }
  }
          )
}

DeleteCaseButton <- function(label="Delete"){
  gbutton(label,
          handler=function(h,...)
          {
            if (is_projOpen(env=.rqda,conName="qdacon") &
                length(svalue(.rqda$.CasesNamesWidget))!=0) {
              del <- gconfirm("Really delete the Case?",icon="question")
              if (isTRUE(del)){
                SelectedCase <- svalue(.rqda$.CasesNamesWidget)
                Encoding(SelectedCase) <- "UTF-8"
                dbGetQuery(.rqda$qdacon,sprintf("update cases set status=0 where name=='%s'",SelectedCase))
                ## set status in table freecode to 0
                CaseNamesUpdate()
              }
                                 }
          }
          )
}

Case_RenameButton <- function(label="Rename",CaseNamesWidget=.rqda$.CasesNamesWidget,...)
{
  ## rename of selected case.
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      selectedCaseName <- svalue(CaseNamesWidget)
      if (length(selectedCaseName)==0){
        gmessage("Select a Case first.",text=selectedCaseName,icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewName <- ginput("Enter new Case name. ", text=selectedCaseName, icon="info")
        if (NewName != ""){
          Encoding(NewName) <- "UTF-8"
          rename(selectedCaseName,NewName,"cases")
        }
      }
    }
  }
          )
}



CaseMemoButton <- function(label="Memo",...){
  gbutton(label, handler=function(h,...) {
    ## code memo: such as meaning of code etc.
    if (is_projOpen(env=.rqda,"qdacon")) {
      currentCase <- svalue(.rqda$.CasesNamesWidget)
      if (length(currentCase)==0){
        gmessage("Select a Case first.",icon="error",con=TRUE)
      }
      else {
        tryCatch(dispose(.rqda$.casememo),error=function(e) {})
        assign(".casememo",gwindow(title=paste("Case Memo",.rqda$currentCase,sep=":"),
                                   parent=c(370,10),width=600,height=400),env=.rqda)
        .casememo <- .rqda$.casememo
        .casememo2 <- gpanedgroup(horizontal = FALSE, con=.casememo)
        gbutton("Save Case Memo",con=.casememo2,handler=function(h,...){
          newcontent <- svalue(W)
          Encoding(newcontent) <- "UTF-8"
          newcontent <- enc(newcontent) ## take care of double quote.
          Encoding(currentCase) <- "UTF-8"
          dbGetQuery(.rqda$qdacon,sprintf("update cases set memo='%s' where name='%s'",newcontent,currentCase))
        }
                )## end of save memo button
        assign(".casememoW",gtext(container=.casememo2,font.attr=c(sizes="large")),env=.rqda)
        prvcontent <- dbGetQuery(.rqda$qdacon, sprintf("select memo from cases where name='%s'",currentCase))[1,1]
        if (is.na(prvcontent)) prvcontent <- ""
        Encoding(prvcontent) <- "UTF-8"
        W <- .rqda$.casememoW
        add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
      }
    }
  }
          )
}


CaseMark_Button<-function(){
  gbutton("Mark",
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              con <- .rqda$qdacon
                                   tryCatch({
                                     ans <- mark(get(h$action$widget,env=.rqda),fore.col=NULL,back.col=.rqda$back.col)
                                     ## can change the color
                                     if (ans$start != ans$end){ 
                                       ## when selected no text, makes on sense to do anything.
                                       SelectedCase <- svalue(.rqda$.CasesNamesWidget)
                                       Encoding(SelectedCase) <- "UTF-8"
                                       currentCid <-  dbGetQuery(con,sprintf("select id from cases where name=='%s'",
                                                                             SelectedCase))[,1]
                                       SelectedFile <- svalue(.rqda$.root_edit)
                                       Encoding(SelectedFile) <- "UTF-8"
                                       currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",
                                                                             SelectedFile))[,1]
                                       DAT <- data.frame(cid=currentCid,fid=currentFid,
                                                         selfirst=ans$start,selend=ans$end,status=1,
                                                         owner=.rqda$owner,date=date(),memo="")
                                       success <- dbWriteTable(.rqda$qdacon,"caselinkage",DAT,row.name=FALSE,append=TRUE)
                                       if (!success) gmessage("Fail to write to database.")
                                     }
                                   },error=function(e){}
                                            )
            }
          },
          action=list(widget=".openfile_gui")
          )
}


AddWebSearchButton <- function(label="WebSearch",CaseNamesWidget=.rqda$.CasesNamesWidget){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
    KeyWord <- svalue(CaseNamesWidget)
    engine <- select.list(c("Baidu","Google","Yahoo"))
    if (engine=="Baidu") {
    KeyWord <- iconv(KeyWord, from="UTF-8")
    browseURL(sprintf("http://www.baidu.com/s?wd=%s",paste("%",paste(charToRaw(KeyWord),sep="",collapse="%"),sep="",collapse="")))
    }
    if (engine=="Yahoo") {
    KeyWord <- iconv(KeyWord, from="UTF-8")
    browseURL(sprintf("http://search.yahoo.com/search;_ylt=A0oGkmFV.CZJNssAOK.l87UF?p=%s&ei=UTF-8&iscqry=&fr=sfp&fr2=sfp"
                     ,KeyWord))
     }
    if (engine=="Google")browseURL(sprintf("http://www.google.com/search?q=%s",KeyWord))
    }
          }
          )
}

CaseNamesWidgetMenu <- list()
CaseNamesWidgetMenu$WebSearch$Baidu$handler <- function(h,...){
    KeyWord <- svalue(.rqda$.CasesNamesWidget)
    if (length(KeyWord)!=0){
    KeyWord <- iconv(KeyWord, from="UTF-8")
    browseURL(sprintf("http://www.baidu.com/s?wd=%s",paste("%",paste(charToRaw(KeyWord),sep="",collapse="%"),sep="",collapse="")))
}
}
CaseNamesWidgetMenu$WebSearch$Google$handler <- function(h,...){
    KeyWord <- svalue(.rqda$.CasesNamesWidget)
    if (length(KeyWord)!=0){
    KeyWord <- iconv(KeyWord, from="UTF-8")
    browseURL(sprintf("http://www.google.com/search?q=%s",KeyWord))
}
}
CaseNamesWidgetMenu$WebSearch$Yahoo$handler <- function(h,...){
    KeyWord <- svalue(.rqda$.CasesNamesWidget)
    if (length(KeyWord)!=0){
    KeyWord <- iconv(KeyWord, from="UTF-8")
    browseURL(sprintf("http://search.yahoo.com/search;_ylt=A0oGkmFV.CZJNssAOK.l87UF?p=%s&ei=UTF-8&iscqry=&fr=sfp&fr2=sfp"
                     ,KeyWord))
}
}


## pop-up menu of add to case
AddFileToCaseMenu <- list()
AddFileToCaseMenu$AddFileTo$handler <- function(h, ...) {
    if (is_projOpen(env = .rqda, conName = "qdacon", message = FALSE)) {
      AddFileToCaselinkage()
    }
  }
