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
