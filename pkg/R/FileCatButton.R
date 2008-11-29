#################
AddFileCatButton <- function(label="ADD"){
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      item <- ginput("Enter new File Category. ", icon="info")
      Encoding(item) <- "UTF-8"
      AddTodbTable(item,"filecat",Id="catid") ## FILE CATegory
      UpdateTableWidget(Widget=.rqda$.FileCatWidget,FromdbTable="filecat")
    }
          }
          )
}


DeleteFileCatButton <- function(label="Delete"){
  gbutton(label,
          handler=function(h,...)
          {
            if (is_projOpen(env=.rqda,conName="qdacon") &
                length(svalue(.rqda$.FileCatWidget))!=0) {
              del <- gconfirm("Really delete the File Category?",icon="question")
              if (isTRUE(del)){
                Selected <- svalue(.rqda$.FileCatWidget)
                Encoding(Selected) <- "UTF-8"
                catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from filecat where status==1 and name=='%s'",Selected))[,1]
                if (length(catid) ==1){
                  dbGetQuery(.rqda$qdacon,sprintf("update filecat set status=0 where name=='%s'",Selected))
                  ## set status in table freecode to 0
                  UpdateTableWidget(Widget=.rqda$.FileCatWidget,FromdbTable="filecat")
                  tryCatch(dbGetQuery(.rqda$qdacon,sprintf("update treefile set status=0 where catid=='%s'",catid)),error=function(e){}) 
                  ## should delete all the related codelists
                  UpdateFileofCatWidget() ## update the filecode of cat widget
                } else gmessage("The Category Name is not unique.",con=TRUE)
                
              }
            }
          }
          )
}


FileCat_RenameButton <- function(label="Rename",Widget=.rqda$.FileCatWidget,...)
{
  ## rename of selected file cat.
  gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,"qdacon")) {
      ## if project is open, then continue
      OldName <- svalue(Widget)
      if (length(OldName)==0){
        gmessage("Select a File Category first.",icon="error",con=TRUE)
      }
      else {
        ## get the new file names
        NewName <- ginput("Enter new Cateory name. ", icon="info")
        Encoding(NewName) <- "UTF-8"
        rename(OldName,NewName,"filecat")
        UpdateTableWidget(Widget=.rqda$.FileCatWidget,FromdbTable="filecat")
      }
    }
  }
          )
}

UpdateFileofCatWidget <- function(con=.rqda$qdacon,Widget=.rqda$.FileofCat){
  SelectedFileCat <- svalue(.rqda$.FileCatWidget)
  if (length(SelectedFileCat)!=0){
    Encoding(SelectedFileCat) <- "UTF-8"
    catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from filecat where status=1 and name='%s'",SelectedFileCat))[,1]
    Total_fid <- dbGetQuery(con,sprintf("select fid from treefile where status==1 and catid==%i",catid))
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

FileCatAddToButton <- function(label="AddTo",Widget=.rqda$.FileCatWidget,...)
{
  gbutton(label,handler=function(h,...) {
    SelectedFileCat <- svalue(.rqda$.FileCatWidget)
    catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from filecat where status=1 and name='%s'",SelectedFileCat))[,1]
    freefile <-  dbGetQuery(.rqda$qdacon,"select name, id from source where status=1")
    Encoding(SelectedFileCat) <- Encoding(freefile[['name']]) <- "UTF-8"
    fileofcat <- dbGetQuery(.rqda$qdacon,sprintf("select fid from treefile where status=1 and catid=%i",catid))
    if (nrow(fileofcat)!=0){
    fileoutofcat <- subset(freefile,!(id %in% fileofcat$fid))
  } else  fileoutofcat <- freefile
    Selected <- select.list(fileoutofcat[['name']],multiple=TRUE)
    if (length(Selected)!=0){
      Selected <- iconv(Selected,to="UTF-8")
      fid <- fileoutofcat[fileoutofcat$name %in% Selected,"id"]
      Dat <- data.frame(fid=fid,catid=catid,date=date(),dateM=date(),memo="",status=1)
      dbWriteTable(.rqda$qdacon,"treefile",Dat,row.names=FALSE,append=TRUE)
      UpdateFileofCatWidget()
  }
}
          )
}

FileCatDropFromButton <- function(label="DropFrom",Widget=.rqda$.FileofCat,...)
{
  gbutton(label,handler=function(h,...) {
    FileOfCat <- svalue(Widget)
    if ((NumofSelected <- length(FileOfCat)) ==0) {
      gmessage("Please select the Files you want to delete.",con=TRUE)} else
    {
      ## Give a confirm msg
      del <- gconfirm(sprintf("Delete %i file(s) from this category. Are you sure?",NumofSelected),con=TRUE,icon="question")
      if (isTRUE(del)){
        SelectedFileCat <- svalue(.rqda$.FileCatWidget)
        Encoding(SelectedFileCat) <- Encoding(FileOfCat)<- "UTF-8"
        catid <- dbGetQuery(.rqda$qdacon,sprintf("select catid from filecat where status=1 and name='%s'",SelectedFileCat))[,1]
    for (i in FileOfCat){
      fid <- dbGetQuery(.rqda$qdacon,sprintf("select id from source where status=1 and name='%s'",i))[,1]
      dbGetQuery(.rqda$qdacon,sprintf("update treefile set status==0 where catid==%i and fid==%i",catid,fid))
    }
        ## update .CodeofCat Widget
        UpdateFileofCatWidget()
      }
    }
  }
          )
}
