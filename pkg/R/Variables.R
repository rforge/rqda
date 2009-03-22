UpgradeTables <- function(){
  Fields <- dbListFields(.rqda$qdacon,"project")
  if (!"databaseversion" %in% Fields) {
    dbGetQuery(.rqda$qdacon,"alter table project add column databaseversion text")
    dbGetQuery(.rqda$qdacon,"update project set databaseversion=='0.1.5'")
  }
  currentVersion <- dbGetQuery(.rqda$qdacon,"select databaseversion from project")[[1]]
  if (currentVersion=="0.1.5") {
    ##from="0.1.5"
    dbGetQuery(.rqda$qdacon,"create table caseAttr (variable text, value text, caseID integer, date text, dateM text, owner text)")
    ## caseAttr table
    dbGetQuery(.rqda$qdacon,"create table fileAttr (variable text, value text, fileID integer, date text, dateM text, owner text)")
    ## fileAttr table
    dbGetQuery(.rqda$qdacon,"create table attributes (name text, status integer, date text, dateM text, owner text, memo text)")
    ## attributes table
    dbGetQuery(.rqda$qdacon,"update project set databaseversion='0.1.6'")
    ## reset the version.
  }
}


AttrNamesUpdate <- function(Widget=.rqda$.AttrNamesWidget,sortByTime=FALSE,decreasing=FALSE,...)
{
  if (isIdCurrent(.rqda$qdacon)){
    attr <- dbGetQuery(.rqda$qdacon, "select name, date from attributes where status=1")
    if (nrow(attr)==0) {
      attr <- NULL
    } else {
      attr <- attr$name
      Encoding(attr) <- "UTF-8"
      if (!sortByTime) {attr <- sort(attr)} else {
        attr <- attr[OrderByTime(attr$date,decreasing=decreasing)]
      }
    }
    tryCatch(Widget[] <- attr, error=function(e){})
  }
}

AddAttrNames <- function(name,...) {
  if (name != ""){
    con <- .rqda$qdacon
    dup <- dbGetQuery(con,sprintf("select name from attributes where name=='%s'",name))
    if (nrow(dup)==0) {
      dbGetQuery(con,sprintf("insert into attributes (name,status,date,owner) values ('%s', %i,%s, %s)",
                             name,1, shQuote(date()),shQuote(.rqda$owner)))
    }
  }
}

AddAttrButton <- function(label="ADD"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      AttrName <- ginput("Enter new Attr Name. ", icon="info")
      if (!is.na(AttrName)) {
        Encoding(AttrName) <- "UTF-8"
        AddAttrNames(AttrName)
        AttrNamesUpdate()
      }
    }
  }
          )
}

DeleteAttrButton <- function(label="Delete"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon") & length(svalue(.rqda$.AttrNamesWidget))!=0)
          {
            del <- gconfirm("Really delete the Attribute?",icon="question")
            if (isTRUE(del)){
              Selected <- svalue(.rqda$.AttrNamesWidget)
              Encoding(Selected) <- "UTF-8"
              dbGetQuery(.rqda$qdacon,sprintf("update attributes set status=0 where name=='%s'",Selected))
              dbGetQuery(.rqda$qdacon,sprintf("delete from caseAttr where variable=='%s'",Selected))
              dbGetQuery(.rqda$qdacon,sprintf("update from fileAttr where variable=='%s'",Selected))
              AttrNamesUpdate()
            }
          }
  }
          )
}

RenameAttrButton <- function(label="Rename"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      selected <- svalue(.rqda$.AttrNamesWidget)
      if (length(selected)==0){
        gmessage("Select a attribute first.",icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewName <- ginput("Enter new attribute name. ", text=selected, icon="info")
        if (!is.na(NewName)){
          Encoding(NewName) <- "UTF-8"
          dbGetQuery(.rqda$qdacon, sprintf("update attributes set name = '%s' where name == '%s' ",NewName,selected))
          dbGetQuery(.rqda$qdacon, sprintf("update caseAttr set variable = '%s' where variable == '%s' ",NewName,selected))
          dbGetQuery(.rqda$qdacon, sprintf("update fileAttr set variable = '%s' where variable == '%s' ",NewName,selected))
          AttrNamesUpdate()
        }
      }
    }
  }
          )
}

AttrMemoButton <- function(label="Memo"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
    MemoWidget("Attributes",.rqda$.AttrNamesWidget,"attributes")
 }
  }
          )
}

viewCaseAttr <- function(){
DF <- dbGetQuery(.rqda$qdacon,"select variable,value, caseId from caseAttr")
DF <- reshape(DF,v.name="value",idvar="caseID",direction="wide",timevar="variable")
names(DF) <- gsub("^value.","",names(DF))
caseName <- dbGetQuery(.rqda$qdacon,"select name,id from cases where status==1")
if (nrow(caseName)!=0){
names(caseName) <- c("case","caseID")
Encoding(caseName$case) <- "UTF-8"
DF <- merge(caseName,DF)
gtable(DF,con=TRUE)
}
}

viewFileAttr <- function(){
DF <- dbGetQuery(RQDA:::.rqda$qdacon,"select variable,value, fileId from fileAttr")
DF <- reshape(DF,v.name="value",idvar="fileID",direction="wide",timevar="variable")
names(DF) <- gsub("^value.","",names(DF))
fileName <- dbGetQuery(.rqda$qdacon,"select name,id from source where status==1")
if (nrow(fileName)!=0){
names(fileName) <- c("file","fileID")
Encoding(fileName$case) <- "UTF-8"
DF <- merge(fileName,DF)
gtable(DF,con=TRUE)
}
}
