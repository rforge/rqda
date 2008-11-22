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
                tryCatch(dbGetQuery(.rqda$qdacon,sprintf("update treecode set status=0 where cid=='%s'",catid)),error=function(e){})
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

CodeCatAddToButton <- function(label="AddTo",Widget=.rqda$.CodeCatWidget,...)
{
  gbutton(label,handler=function(h,...) {
  Selected <- select.list()
}
)
}

