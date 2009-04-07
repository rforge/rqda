AddJournalButton <- function(label="ADD"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      JournalNamesUpdate()
    }
  }
          )
}

DeleteJournalButton <- function(label="Delete"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon") & length(svalue(.rqda$.JournalNamesWidget))!=0)
      {
        del <- gconfirm("Really delete the journal?",icon="question")
        if (isTRUE(del)){
          Selected <- svalue(.rqda$.JouranlNamesWidget)
          Encoding(Selected) <- "UTF-8"
          dbGetQuery(.rqda$qdacon,sprintf("update attributes set status=0 where date=='%s'",Selected))
          JournalNamesUpdate()
        }
      }
  }
          )
}


JournalNamesUpdate <- function(Widget=.rqda$.JournalNamesWidget,decreasing=FALSE,...)
{
  if (isIdCurrent(.rqda$qdacon)){
    journal <- dbGetQuery(.rqda$qdacon, "select date from attributes where status=1")
    if (nrow(journal)==0) {
      journal <- NULL
    } else {
      journal <- journal[OrderByTime(journal[,1],decreasing=decreasing)]
    }
    tryCatch(Widget[] <- journal, error=function(e){})
  }
}

AddNewJournalFun <- function(){
  if (is_projOpen(env=.rqda,"qdacon")) {
    
  }
}
