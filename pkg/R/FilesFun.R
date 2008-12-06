ImportFile <- function(path,encoding=.rqda$encoding,con=.rqda$qdacon,...){
  ## import a file into a DBI connection _con_.
  Fname <- gsub("\\.[[:alpha:]]*$","",basename(path))## Fname is in locale Encoding Now.
  FnameUTF8 <- iconv(Fname,to="UTF-8")
  ## remove the suffix such as .txt
  if ( Fname!="" ) {
    file_con <- file(path,open="r")
    if (isTRUE(.rqda$BOM)) seek(file_con,3)
    content <- readLines(file_con,warn=FALSE,encoding=encoding)
    close(file_con)
    content <- paste(content,collapse="\n")
    content <- enc(content)
    if (Encoding(content)!="UTF-8"){
      content <- iconv(content,to="UTF-8") ## UTF-8 file content
    }
    maxid <- dbGetQuery(con,"select max(id) from source")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    ## check if the content should be written into con.
    if (nextid==1) {
      write <- TRUE
      ## if this is the first file, no need to worry about the duplication issue.
    } else {
      if (nrow(dbGetQuery(con,sprintf("select name from source where name=='%s'",FnameUTF8)))==0) {
        ## no duplication file exists, then write.
        write <- TRUE
      } else {
        gmessage("A file withe the same name exists in the database!")
      }
    }
    if (write ) {
      dbGetQuery(con,sprintf("insert into source (name, file, id, status,date,owner )
                             values ('%s', '%s',%i, %i, '%s', '%s')",
                             Fname,content, nextid, 1,date(),.rqda$owner))
    } 
  }
}



FileNamesUpdate <- function(FileNamesWidget=.rqda$.fnames_rqda,...){
  ##update file names list in the FileNamesWidget
  wopt <- options(warn=-2)
  on.exit(options(wopt))
  fnames <- dbGetQuery(.rqda$qdacon, "select name, id from source where status=1")
  if (nrow(fnames)!=0) Encoding(fnames[['name']]) <- "UTF-8"
  tryCatch(FileNamesWidget[] <- fnames[['name']],error=function(e){})
}



setEncoding <- function(encoding="unknown"){
  ## specify what encoding is used in the imported files.
  .rqda$encoding <- encoding
}

enc <- function(x) gsub("'", "''", x)
## replace " with two '. to make insert smoothly.

ViewFileFun <- function(FileNameWidget){
## FileNameWidget=.rqda$.fnames_rqda in Files Tab
## FileNameWidget=.rqda$.FileofCat in F-CAT Tab
        if (is_projOpen(env = .rqda, conName = "qdacon")) {
            if (length(svalue(FileNameWidget)) == 0) {
                gmessage("Select a file first.", icon = "error", 
                  con = TRUE)
            }
            else {
                tryCatch(dispose(.rqda$.root_edit), error = function(e) {
                })
                SelectedFileName <- svalue(FileNameWidget)
                assign(".root_edit", gwindow(title = SelectedFileName, 
                  parent = c(395, 10), width = 600, height = 600), 
                  env = .rqda)
                .root_edit <- get(".root_edit", .rqda)
                assign(".openfile_gui", gtext(container = .root_edit, 
                  font.attr = c(sizes = "large")), env = .rqda)
                Encoding(SelectedFileName) <- "unknown"
                IDandContent <- dbGetQuery(.rqda$qdacon, sprintf("select id, file from source where name='%s'", 
                  SelectedFileName))
                content <- IDandContent$file
                Encoding(content) <- "UTF-8"
                W <- get(".openfile_gui", .rqda)
                add(W, content, font.attr = c(sizes = "large"))
                slot(W, "widget")@widget$SetEditable(FALSE)
                mark_index <-
                  dbGetQuery(.rqda$qdacon,sprintf("select selfirst,selend from coding where fid=%i and status=1",IDandContent$id))
                if (nrow(mark_index)!=0){
                ## make sense only when there is coding there
                  ClearMark(W ,0 , max(mark_index$selend))
                  HL(W,index=mark_index)
                }
            }
        }
    }


write.FileList <- function(FileList,encoding=.rqda$encoding,con=.rqda$qdacon,...){
  ## import a list of files into the source table
  ## FileList is a list of file content, with names(FileList) the name of the files.
  WriteToTable <- function(Fname,content){
    ## helper function
    FnameUTF8 <- iconv(Fname,to="UTF-8")
    content <- enc(content)
    if (Encoding(content)!="UTF-8"){
      content <- iconv(content,to="UTF-8") ## UTF-8 file content
    }
    maxid <- dbGetQuery(con,"select max(id) from source")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
  ## check if the content should be written into con.
    if (nextid==1) {
      write <- TRUE
      ## if this is the first file, no need to worry about the duplication issue.
    } else {
      if (nrow(dbGetQuery(con,sprintf("select name from source where name=='%s'",FnameUTF8)))==0) {
      ## no duplication file exists, then write.
        write <- TRUE
      } else {
        cat(sprintf("%s exists in the database!\n",Fname))
      }
    }
  if (write ) {
    dbGetQuery(con,sprintf("insert into source (name, file, id, status,date,owner )
                             values ('%s', '%s',%i, %i, '%s', '%s')",
                           Fname,content, nextid, 1,date(),.rqda$owner))
  }
  }
  FileNames <- names(FileList)
  FileNames[FileNames==""] <- as.character(1:sum(FileNames==""))

  if (isIdCurrent(con)) {
    for (i in 1:length(FileList)) {
      WriteToTable(FileNames[i],FileList[[i]])
    }
    FileNamesUpdate(FileNamesWidget=.rqda$.fnames_rqda)
    } else gmessage("Open a project first.", con=TRUE)
}
