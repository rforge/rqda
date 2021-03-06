### UpdateTableWidget() and AddTodbTable() are generall version of the previous functions
UpdateTableWidget <- function(Widget,FromdbTable,con=.rqda$qdacon,...)
{
  if (isIdCurrent(con)){
  items <- dbGetQuery(con, sprintf("select name from %s where status=1",FromdbTable))
  if (nrow(items)!=0) {
    items <- items[['name']]
    Encoding(items) <- "UTF-8"
  } else items <- NULL
    tryCatch(eval(substitute(W[] <- items,list(W=quote(Widget)))), error=function(e){})
  }
}


AddTodbTable <- function(item,dbTable,Id="id",field="name",con=.rqda$qdacon,...) {
  if (item != ""){
    maxid <- dbGetQuery(con,sprintf("select max(%s) from %s",Id, dbTable))[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    if (nextid==1){
      write <- TRUE
    } else {
      dup <- dbGetQuery(con,sprintf("select %s from %s where name=='%s'",field, dbTable, item))
      if (nrow(dup)==0) write <- TRUE
    }
    if (write ) {
      dbGetQuery(con,sprintf("insert into %s (%s, %s, status,date,owner)
                                            values ('%s', %i, %i,%s, %s)",dbTable,field,Id,
                             item,nextid, 1, shQuote(date()),shQuote(.rqda$owner)))
    }
  }
}


#################
AddCodeCatButton <- function(label="ADD"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      item <- ginput("Enter new Code Category. ", icon="info")
      Encoding(item) <- "UTF-8"
      AddTodbTable(item,"codecat",Id="catid") ## CODE CATegory
      UpdateTableWidget(Widget=.rqda$.CodeCatWidget,FromdbTable="codecat")
    }
          }
          )
}


DeleteCodeCatButton <- function(label="Delete"){
  gbutton(label,
          handler=function(h,...)
          {
            if (is_projOpen(env=.rqda,conName="qdacon") &
                length(svalue(.rqda$.CodeCatWidget))!=0) {
              del <- gconfirm("Really delete the Code Category?",icon="question")
              if (isTRUE(del)){
                Selected <- svalue(.rqda$.CodeCatWidget)
                Encoding(Selected) <- "UTF-8"
                catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from codecat where status==1 and name=='%s'",Selected))[,1]
                if (length(catid) ==1){
                  dbGetQuery(.rqda$qdacon,sprintf("update codecat set status=0 where name=='%s'",Selected))
                  ## set status in table freecode to 0
                  UpdateTableWidget(Widget=.rqda$.CodeCatWidget,FromdbTable="codecat")
                  tryCatch(dbGetQuery(.rqda$qdacon,sprintf("update treecode set status=0 where catid=='%s'",catid)),error=function(e){}) 
                  ## should delete all the related codelists
                  UpdateCodeofCatWidget() ## update the code of cat widget
                } else gmessage("The Category Name is not unique.",con=T)
                
              }
            }
          }
          )
}


CodeCat_RenameButton <- function(label="Rename",Widget=.rqda$.CodeCatWidget,...)
{
  ## rename of selected code cat.
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      OldName <- svalue(Widget)
      if (length(OldName)==0){
        gmessage("Select a Code Category first.",icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewName <- ginput("Enter new Cateory name. ", icon="info")
        Encoding(NewName) <- "UTF-8"
        rename(OldName,NewName,"codecat")
        UpdateTableWidget(Widget=.rqda$.CodeCatWidget,FromdbTable="codecat")
      }
    }
  }
          )
}

UpdateCodeofCatWidget <- function(con=.rqda$qdacon,Widget=.rqda$.CodeofCat){
  SelectedCodeCat <- svalue(.rqda$.CodeCatWidget)
  if (length(SelectedCodeCat)!=0){
    ## if code cat is selected, then continue
    Encoding(SelectedCodeCat) <- "UTF-8"
    catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from codecat where status=1 and name='%s'",SelectedCodeCat))[,1]
    Total_cid <- dbGetQuery(con,sprintf("select cid from treecode where status==1 and catid==%i",catid))
    if (nrow(Total_cid)!=0){
      items <- dbGetQuery(con,"select name,id from freecode where status==1")
      if (nrow(items)!=0) {
        items <- items[items$id %in% Total_cid$cid,"name"]
        Encoding(items) <- "UTF-8"
      } else items <- NULL
    } else items <- NULL
  } else items <- NULL
    tryCatch(Widget[] <- items,error=function(e){})
}

CodeCatAddToButton <- function(label="AddTo",Widget=.rqda$.CodeCatWidget,...)
{
  gbutton(label,handler=function(h,...) {
    ## SelectedCodeCat and its id (table codecat): svalue()-> Name; sql->catid
    SelectedCodeCat <- svalue(.rqda$.CodeCatWidget)
    catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from codecat where status=1 and name='%s'",SelectedCodeCat))[,1]
    ## CodeList and the id (table freecode): sql -> name and id where status==1
    freecode <-  dbGetQuery(.rqda$qdacon,"select name, id from freecode where status=1")
    Encoding(SelectedCodeCat) <- Encoding(freecode[['name']]) <- "UTF-8"
    ## Get CodeList already in the category (table treecode): sql -> cid where catid==catid
    codeofcat <- dbGetQuery(.rqda$qdacon,sprintf("select cid from treecode where status=1 and catid=%i",catid))
    if (nrow(codeofcat)!=0){
    ## compute those not in the category, then push them to select.list()
    codeoutofcat <- subset(freecode,!(id %in% codeofcat$cid))
    } else  codeoutofcat <- freecode
    Selected <- select.list(codeoutofcat[['name']],multiple=TRUE)
    if (length(Selected)!=0){
    Selected <- iconv(Selected,to="UTF-8")
    cid <- codeoutofcat[codeoutofcat$name %in% Selected,"id"]
    Dat <- data.frame(cid=cid,catid=catid,date=date(),dateM=date(),memo="",status=1)
    ## Push selected codeList to table treecode
    dbWriteTable(.rqda$qdacon,"treecode",Dat,row.names=FALSE,append=TRUE)
    ## update .CodeofCat Widget
    UpdateCodeofCatWidget()
  }
}
          )
}
## update .rqda$.CodeofCat[] by click handler on .rqda$.CodeCatWidget

CodeCatDropFromButton <- function(label="DropFrom",Widget=.rqda$.CodeofCat,...)
{
  gbutton(label,handler=function(h,...) {
    ## Get CodeList already in the category (table treecode): svalue()
    CodeOfCat <- svalue(Widget)
    if ((NumofSelected <- length(CodeOfCat)) ==0) {
      gmessage("Please select the Codes you want to delete.",con=T)} else
    {
      ## Give a confirm msg
      del <- gconfirm(sprintf("Delete %i code(s) from this category. Are you sure?",NumofSelected),con=T,icon="question")
      if (isTRUE(del)){
        ## set status==0 for those selected CodeList (table treecode)
    SelectedCodeCat <- svalue(.rqda$.CodeCatWidget)
    Encoding(SelectedCodeCat) <- Encoding(CodeOfCat)<- "UTF-8"
    catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from codecat where status=1 and name='%s'",SelectedCodeCat))[,1]
    for (i in CodeOfCat){
    cid <- dbGetQuery(.rqda$qdacon,sprintf("select id from freecode where status=1 and name='%s'",i))[,1]
    dbGetQuery(.rqda$qdacon,sprintf("update treecode set status==0 where catid==%i and cid==%i",catid,cid))
  }
    ## update .CodeofCat Widget
    UpdateCodeofCatWidget()
}}
  }
          )
}
