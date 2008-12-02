CaseNamesUpdate <- function(CaseNamesWidget=.rqda$.CasesNamesWidget,...)
{
  if (isIdCurrent(.rqda$qdacon)){
  CaseName <- dbGetQuery(.rqda$qdacon, "select name, id from cases where status=1")
  if (nrow(CaseName)!=0) {
    Encoding(CaseName[['name']]) <- "UTF-8"
    tryCatch(CaseNamesWidget[] <- CaseName[['name']], error=function(e){})
  } else tryCatch(CaseNamesWidget[] <- NULL, error=function(e){}) 
## when nrow(CaseName)==0, update it to NULL
}
}

#################
###############
AddCase <- function(name,conName="qdacon",assignenv=.rqda,...) {
  if (name != ""){
    con <- get(conName,assignenv)
    maxid <- dbGetQuery(con,"select max(id) from cases")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    if (nextid==1){
      write <- TRUE
    } else {
      dup <- dbGetQuery(con,sprintf("select name from cases where name=='%s'",name))
      if (nrow(dup)==0) write <- TRUE
    }
    if (write ) {
      dbGetQuery(con,sprintf("insert into cases (name, id, status,date,owner)
                                            values ('%s', %i, %i,%s, %s)",
                             name,nextid, 1, shQuote(date()),shQuote(.rqda$owner)))
    }
  }
}


CaseMark_Button<-function(){
  gbutton("Mark",
          handler=function(h,...) {
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              con <- .rqda$qdacon
                                   tryCatch({
                                     ans <- mark(get(h$action$widget,env=.rqda)) ## can change the color
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



AddFileToCaselinkage <- function(){
  ## filenames -> fid -> selfirst=0; selend=nchar(filesource)
  filename <- svalue(.rqda$.fnames_rqda)
  Encoding(filename) <- "unknown"
  query <- dbGetQuery(.rqda$qdacon,sprintf("select id, file from source where name = '%s' and status=1",filename))
  fid <- query$id
  Encoding(query$file) <- "UTF-8"
  selend <- nchar(query$file)
  
  ## select a case name -> caseid
  cases <- dbGetQuery(.rqda$qdacon,"select id, name from cases where status=1")
  if (nrow(cases)!=0){
    Encoding(cases$name) <- "UTF-8"
    ans <- select.list(cases$name,multiple=FALSE)
    if (length(ans)!=0){
    ans <- iconv(ans,to="UTF-8")
    caseid <- cases$id[cases$name %in% ans]
    
    exist <- dbGetQuery(.rqda$qdacon,sprintf("select fid from caselinkage where status=1 and fid=%i and caseid=%i",fid,caseid))
    if (nrow(exist)==0){
    ## write only when the selected file associated with specific case is not in the caselinkage table
    DAT <- data.frame(caseid=caseid, fid=fid, selfirst=0, selend=selend, status=1,owner=.rqda$owner,data=date(),memo='')
    success <- dbWriteTable(.rqda$qdacon,"caselinkage",DAT,row.name=FALSE,append=TRUE)
    ## write to caselinkage table
    if (!success) gmessage("Fail to write to database.")
   }
  }
}
}


UpdateFileofCaseWidget <- function(con=.rqda$qdacon,Widget=.rqda$.FileofCase){
  Selected <- svalue(.rqda$.CasesNamesWidget)
  if (length(Selected)!=0){
    caseid <- dbGetQuery(.rqda$qdacon,sprintf("select id from cases where status=1 and name='%s'",Selected))[,1]
    ## Encoding(Selected) <- "UTF-8"
    Total_fid <- dbGetQuery(con,sprintf("select fid from caselinkage where status==1 and caseid==%i",caseid))
    if (nrow(Total_fid)!=0){
      items <- dbGetQuery(con,"select name,id from source where status==1")
      if (nrow(items)!=0) {
        items <- items[items$id %in% Total_fid$fid,"name"]
        Encoding(items) <- "UTF-8"
      } else items <- NULL
    } else items <- NULL
  } else items <- NULL
    tryCatch(Widget[] <- items,error=function(e){})
}

HL_Case <- function(){
            if (is_projOpen(env=.rqda,conName="qdacon")) {
              con <- .rqda$qdacon
              SelectedFile <- svalue(.rqda$.root_edit)
              ## Encoding(SelectedFile) <- "UTF-8"
              currentFid <-  dbGetQuery(con,sprintf("select id from source where name=='%s'",SelectedFile))[,1]
              W <- .rqda$.openfile_gui
              if (length(currentFid)!=0) {
                mark_index <-
                  dbGetQuery(con,sprintf("select selfirst,selend from caselinkage where fid=%i and status==1",currentFid))
                if (nrow(mark_index)!=0){
                  ClearMark(W ,0 , max(mark_index$selend))
                  HL(W,index=mark_index)
                }
              }
            }
          }
